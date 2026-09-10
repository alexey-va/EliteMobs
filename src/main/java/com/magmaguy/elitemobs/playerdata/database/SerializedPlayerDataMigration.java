package com.magmaguy.elitemobs.playerdata.database;

import java.util.logging.Logger;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.nio.ByteBuffer;
import java.security.MessageDigest;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.HexFormat;
import java.util.List;
import java.util.Set;

/** Converts legacy Java-serialized player state to versioned JSON without discarding the source bytes. */
final class SerializedPlayerDataMigration {

    private static final Logger LOGGER = Logger.getLogger("EliteMobs");

    // The original PlayerDataSerializedLegacy table remains untouched. Its UUID-only primary key
    // cannot retain a second legacy value written by an older server during a rolling upgrade.
    static final String BACKUP_TABLE = "PlayerDataSerializedSnapshots";
    private static final int BATCH_SIZE = 100;
    private static final List<ColumnCodec> COLUMNS = List.of(
            new ColumnCodec("QuestStatus", bytes -> PlayerDataJsonCodec.encodeQuests(PlayerDataJsonCodec.decodeQuests(bytes))),
            new ColumnCodec("PlayerQuestCooldowns", bytes -> PlayerDataJsonCodec.encodePlayerQuestCooldowns(PlayerDataJsonCodec.decodePlayerQuestCooldowns(bytes))),
            new ColumnCodec("DungeonBossLockouts", bytes -> PlayerDataJsonCodec.encodeDungeonBossLockout(PlayerDataJsonCodec.decodeDungeonBossLockout(bytes))),
            new ColumnCodec("QuestLockouts", bytes -> PlayerDataJsonCodec.encodeQuestLockout(PlayerDataJsonCodec.decodeQuestLockout(bytes))));

    private SerializedPlayerDataMigration() {
    }

    static MigrationResult migrate(Connection connection) throws Exception {
        if (!connection.getAutoCommit()) throw new IllegalStateException("Player-data migration requires its own transaction");
        initializeSchema(connection);
        int rowsMigrated = 0;
        int valuesMigrated = 0;
        String cursor = "";
        while (true) {
            List<PlayerRow> rows = readBatch(connection, cursor);
            if (rows.isEmpty()) break;
            cursor = rows.getLast().playerId();

            List<MigratedRow> migratedRows = new ArrayList<>();
            for (PlayerRow row : rows) {
                try {
                    MigratedRow migrated = convert(row);
                    if (migrated != null) migratedRows.add(migrated);
                } catch (Exception exception) {
                    LOGGER.warning("Could not migrate legacy serialized player data for UUID " + row.playerId()
                            + "; the original BLOBs were left unchanged.");
                    exception.printStackTrace();
                }
            }
            if (migratedRows.isEmpty()) continue;
            MigrationResult result = writeBatch(connection, migratedRows);
            rowsMigrated += result.rows();
            valuesMigrated += result.values();
        }
        return new MigrationResult(rowsMigrated, valuesMigrated);
    }

    private static void initializeSchema(Connection connection) throws Exception {
        try (Statement statement = connection.createStatement()) {
            statement.executeUpdate("CREATE TABLE IF NOT EXISTS " + BACKUP_TABLE + " ("
                    + "PlayerUUID VARCHAR(36) NOT NULL, SnapshotHash CHAR(64) NOT NULL, "
                    + "QuestStatus MEDIUMBLOB, PlayerQuestCooldowns MEDIUMBLOB, "
                    + "DungeonBossLockouts MEDIUMBLOB, QuestLockouts MEDIUMBLOB, MigratedAt BIGINT NOT NULL, "
                    + "PRIMARY KEY (PlayerUUID, SnapshotHash))" + (isMySQL(connection) ? " ENGINE=InnoDB" : ""));
        }
    }

    private static List<PlayerRow> readBatch(Connection connection, String cursor) throws Exception {
        String sql = "SELECT PlayerUUID, QuestStatus, PlayerQuestCooldowns, DungeonBossLockouts, QuestLockouts "
                + "FROM " + PlayerData.getPLAYER_DATA_TABLE_NAME() + " WHERE PlayerUUID > ? ORDER BY PlayerUUID LIMIT ?";
        List<PlayerRow> rows = new ArrayList<>();
        try (PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, cursor);
            statement.setInt(2, BATCH_SIZE);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next())
                    rows.add(new PlayerRow(resultSet.getString(1), resultSet.getBytes(2), resultSet.getBytes(3),
                            resultSet.getBytes(4), resultSet.getBytes(5)));
            }
        }
        return rows;
    }

    private static MigratedRow convert(PlayerRow row) throws Exception {
        byte[][] original = row.values();
        byte[][] converted = new byte[original.length][];
        boolean hasLegacy = false;
        for (int index = 0; index < original.length; index++) {
            byte[] bytes = original[index];
            if (bytes == null || PlayerDataJsonCodec.isJson(bytes)) continue;
            hasLegacy = true;
            converted[index] = COLUMNS.get(index).converter().convert(bytes);
        }
        return hasLegacy ? new MigratedRow(row.playerId(), original, converted) : null;
    }

    private static MigrationResult writeBatch(Connection connection, List<MigratedRow> rows) throws Exception {
        String backupSql = "INSERT INTO " + BACKUP_TABLE
                + " (PlayerUUID, QuestStatus, PlayerQuestCooldowns, DungeonBossLockouts, QuestLockouts, MigratedAt, SnapshotHash)"
                + " VALUES (?, ?, ?, ?, ?, ?, ?)"
                + (isMySQL(connection) ? " ON DUPLICATE KEY UPDATE SnapshotHash = SnapshotHash"
                : " ON CONFLICT (PlayerUUID, SnapshotHash) DO NOTHING");
        boolean oldAutoCommit = connection.getAutoCommit();
        connection.setAutoCommit(false);
        try (PreparedStatement backup = connection.prepareStatement(backupSql)) {
            List<PreparedStatement> updates = new ArrayList<>();
            try {
                for (ColumnCodec column : COLUMNS)
                    updates.add(connection.prepareStatement("UPDATE " + PlayerData.getPLAYER_DATA_TABLE_NAME()
                            + " SET " + column.name() + " = ? WHERE PlayerUUID = ? AND " + column.name() + " = ?"));
                for (MigratedRow row : rows) {
                    backup.setString(1, row.playerId());
                    for (int index = 0; index < row.original().length; index++)
                        backup.setBytes(index + 2, row.original()[index]);
                    backup.setLong(6, System.currentTimeMillis());
                    backup.setString(7, snapshotHash(row.original()));
                    backup.addBatch();

                    for (int index = 0; index < row.converted().length; index++) {
                        if (row.converted()[index] == null) continue;
                        PreparedStatement update = updates.get(index);
                        update.setBytes(1, row.converted()[index]);
                        update.setString(2, row.playerId());
                        update.setBytes(3, row.original()[index]);
                        update.addBatch();
                    }
                }
                backup.executeBatch();
                Set<String> changedRows = new HashSet<>();
                int changedValues = 0;
                for (int index = 0; index < updates.size(); index++) {
                    int[] counts = updates.get(index).executeBatch();
                    int position = 0;
                    for (MigratedRow row : rows) {
                        if (row.converted()[index] == null) continue;
                        int count = counts[position++];
                        if (count == Statement.EXECUTE_FAILED) throw new java.sql.SQLException("Player-data migration batch failed");
                        if (count > 0 || count == Statement.SUCCESS_NO_INFO) {
                            changedValues++;
                            changedRows.add(row.playerId());
                        }
                    }
                }
                connection.commit();
                return new MigrationResult(changedRows.size(), changedValues);
            } finally {
                for (PreparedStatement update : updates) update.close();
            }
        } catch (Exception exception) {
            connection.rollback();
            throw exception;
        } finally {
            connection.setAutoCommit(oldAutoCommit);
        }
    }

    private static boolean isMySQL(Connection connection) throws Exception {
        String product = connection.getMetaData().getDatabaseProductName().toLowerCase(java.util.Locale.ROOT);
        return product.contains("mysql") || product.contains("mariadb");
    }

    private static String snapshotHash(byte[][] values) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        for (byte[] value : values) {
            digest.update(ByteBuffer.allocate(Integer.BYTES).putInt(value == null ? -1 : value.length).array());
            if (value != null) digest.update(value);
        }
        return HexFormat.of().formatHex(digest.digest());
    }

    private record PlayerRow(String playerId, byte[] questStatus, byte[] playerQuestCooldowns,
                             byte[] dungeonBossLockouts, byte[] questLockouts) {
        byte[][] values() {
            return new byte[][]{questStatus, playerQuestCooldowns, dungeonBossLockouts, questLockouts};
        }
    }

    private record MigratedRow(String playerId, byte[][] original, byte[][] converted) {
    }

    private record ColumnCodec(String name, Converter converter) {
    }

    record MigrationResult(int rows, int values) {
    }

    @FunctionalInterface
    private interface Converter {
        byte[] convert(byte[] bytes) throws Exception;
    }
}
