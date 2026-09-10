package com.magmaguy.elitemobs.playerdata.database;

import com.magmaguy.magmacore.util.Logger;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

/** Converts legacy Java-serialized player state to versioned JSON without discarding the source bytes. */
final class SerializedPlayerDataMigration {

    static final String BACKUP_TABLE = "PlayerDataSerializedLegacy";
    private static final int BATCH_SIZE = 100;
    private static final List<ColumnCodec> COLUMNS = List.of(
            new ColumnCodec("QuestStatus", bytes -> PlayerDataJsonCodec.encodeQuests(PlayerDataJsonCodec.decodeQuests(bytes))),
            new ColumnCodec("PlayerQuestCooldowns", bytes -> PlayerDataJsonCodec.encodePlayerQuestCooldowns(PlayerDataJsonCodec.decodePlayerQuestCooldowns(bytes))),
            new ColumnCodec("DungeonBossLockouts", bytes -> PlayerDataJsonCodec.encodeDungeonBossLockout(PlayerDataJsonCodec.decodeDungeonBossLockout(bytes))),
            new ColumnCodec("QuestLockouts", bytes -> PlayerDataJsonCodec.encodeQuestLockout(PlayerDataJsonCodec.decodeQuestLockout(bytes))));

    private SerializedPlayerDataMigration() {
    }

    static MigrationResult migrate(Connection connection) throws Exception {
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
                    Logger.warn("Could not migrate legacy serialized player data for UUID " + row.playerId()
                            + "; the original BLOBs were left unchanged.");
                    exception.printStackTrace();
                }
            }
            if (migratedRows.isEmpty()) continue;
            int[] result = writeBatch(connection, migratedRows);
            rowsMigrated += migratedRows.size();
            for (int changed : result) valuesMigrated += changed;
        }
        return new MigrationResult(rowsMigrated, valuesMigrated);
    }

    private static void initializeSchema(Connection connection) throws Exception {
        try (Statement statement = connection.createStatement()) {
            statement.executeUpdate("CREATE TABLE IF NOT EXISTS " + BACKUP_TABLE + " ("
                    + "PlayerUUID VARCHAR(36) PRIMARY KEY NOT NULL, "
                    + "QuestStatus MEDIUMBLOB, PlayerQuestCooldowns MEDIUMBLOB, "
                    + "DungeonBossLockouts MEDIUMBLOB, QuestLockouts MEDIUMBLOB, MigratedAt BIGINT NOT NULL)");
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

    private static int[] writeBatch(Connection connection, List<MigratedRow> rows) throws Exception {
        boolean mysql = connection.getMetaData().getDatabaseProductName().toLowerCase().contains("mysql")
                || connection.getMetaData().getDatabaseProductName().toLowerCase().contains("mariadb");
        String backupSql = (mysql ? "INSERT IGNORE" : "INSERT OR IGNORE") + " INTO " + BACKUP_TABLE
                + " (PlayerUUID, QuestStatus, PlayerQuestCooldowns, DungeonBossLockouts, QuestLockouts, MigratedAt)"
                + " VALUES (?, ?, ?, ?, ?, ?)";
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
                List<Integer> changed = new ArrayList<>();
                for (PreparedStatement update : updates)
                    for (int count : update.executeBatch()) changed.add(Math.max(count, 0));
                connection.commit();
                return changed.stream().mapToInt(Integer::intValue).toArray();
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
