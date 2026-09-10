package com.magmaguy.elitemobs.playerdata.database;

import com.magmaguy.elitemobs.dungeons.DungeonBossLockout;
import com.magmaguy.elitemobs.utils.ObjectSerializer;
import org.junit.jupiter.api.Test;

import java.io.ByteArrayOutputStream;
import java.io.DataOutputStream;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class PersistenceReviewTest {

    @Test
    void legacyReaderDoesNotRewriteDescriptorLookalikesInPayload() throws Exception {
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        try (DataOutputStream out = new DataOutputStream(bytes)) {
            out.writeByte(0x72);
            out.writeUTF(DungeonBossLockout.class.getName());
            out.writeLong(123456L);
            out.writeLong(654321L);
        }
        byte[] payload = bytes.toByteArray();
        assertArrayEquals(payload, (byte[]) ObjectSerializer.fromString(ObjectSerializer.toString(payload)));
    }

    @Test
    void invalidJsonMustNotBecomeAnEmptyLockout() {
        for (String data : new String[]{"null", "{}", "{\"lockouts\":null}",
                "{\"lockouts\":{\"boss.yml\":null}}", "{\"lockouts\":{\"boss.yml\":1.5}}"}) {
            assertThrows(Exception.class, () -> PlayerDataJsonCodec.decodeDungeonBossLockout(
                    json("1", "dungeon-boss-lockouts", data)), data);
        }
        assertThrows(Exception.class, () -> PlayerDataJsonCodec.decodeDungeonBossLockout(
                json("1.5", "dungeon-boss-lockouts", "{\"lockouts\":{}}")));
    }

    @Test
    void migrationRetainsEveryLegacySnapshotForTheSamePlayer() throws Exception {
        try (Connection db = database()) {
            UUID player = UUID.randomUUID();
            byte[] first = legacyLockout(100);
            byte[] second = legacyLockout(200);
            insert(db, player, first);
            SerializedPlayerDataMigration.migrate(db);
            // An older server can write another legacy value while the network is being upgraded.
            try (PreparedStatement update = db.prepareStatement("UPDATE PlayerData SET DungeonBossLockouts = ?")) {
                update.setBytes(1, second);
                update.executeUpdate();
            }
            SerializedPlayerDataMigration.migrate(db);
            SerializedPlayerDataMigration.migrate(db);
            int snapshots = 0;
            try (Statement statement = db.createStatement(); ResultSet rows = statement.executeQuery(
                    "SELECT DungeonBossLockouts FROM " + SerializedPlayerDataMigration.BACKUP_TABLE)) {
                while (rows.next()) {
                    byte[] saved = rows.getBytes(1);
                    assertTrue(java.util.Arrays.equals(first, saved) || java.util.Arrays.equals(second, saved));
                    snapshots++;
                }
            }
            assertEquals(2, snapshots);
        }
    }

    @Test
    void migrationRollsBackBackupAndChangesTogether() throws Exception {
        try (Connection db = database()) {
            byte[] legacy = legacyLockout(100);
            insert(db, UUID.randomUUID(), legacy);
            try (Statement statement = db.createStatement()) {
                statement.executeUpdate("CREATE TRIGGER reject_migration BEFORE UPDATE ON PlayerData "
                        + "BEGIN SELECT RAISE(ABORT, 'injected write failure'); END");
            }
            assertThrows(Exception.class, () -> SerializedPlayerDataMigration.migrate(db));
            assertTrue(db.getAutoCommit());
            try (Statement statement = db.createStatement(); ResultSet row = statement.executeQuery(
                    "SELECT DungeonBossLockouts FROM PlayerData")) {
                assertTrue(row.next());
                assertArrayEquals(legacy, row.getBytes(1));
            }
            try (Statement statement = db.createStatement(); ResultSet row = statement.executeQuery(
                    "SELECT COUNT(*) FROM " + SerializedPlayerDataMigration.BACKUP_TABLE)) {
                assertTrue(row.next());
                assertEquals(0, row.getInt(1));
            }
        }
    }

    @Test
    void migrationTraversesMultipleBatchesAndIsIdempotent() throws Exception {
        try (Connection db = database()) {
            for (int i = 0; i < 237; i++) insert(db, new UUID(0, i), legacyLockout(i));
            assertEquals(new SerializedPlayerDataMigration.MigrationResult(237, 237),
                    SerializedPlayerDataMigration.migrate(db));
            assertEquals(new SerializedPlayerDataMigration.MigrationResult(0, 0),
                    SerializedPlayerDataMigration.migrate(db));
        }
    }

    static Connection database() throws Exception {
        Connection db = DriverManager.getConnection("jdbc:sqlite::memory:");
        try (Statement statement = db.createStatement()) {
            statement.executeUpdate("CREATE TABLE PlayerData (PlayerUUID VARCHAR(36) PRIMARY KEY NOT NULL, "
                    + "QuestStatus MEDIUMBLOB, PlayerQuestCooldowns MEDIUMBLOB, "
                    + "DungeonBossLockouts MEDIUMBLOB, QuestLockouts MEDIUMBLOB)");
        }
        return db;
    }

    private static void insert(Connection db, UUID player, byte[] legacy) throws Exception {
        try (PreparedStatement insert = db.prepareStatement(
                "INSERT INTO PlayerData (PlayerUUID, DungeonBossLockouts) VALUES (?, ?)")) {
            insert.setString(1, player.toString());
            insert.setBytes(2, legacy);
            insert.executeUpdate();
        }
    }

    private static byte[] legacyLockout(long timestamp) throws Exception {
        DungeonBossLockout lockout = new DungeonBossLockout();
        lockout.getLockouts().put("boss.yml", timestamp);
        return ObjectSerializer.toString(lockout).getBytes(StandardCharsets.UTF_8);
    }

    private static byte[] json(String version, String type, String data) {
        return ("{\"format\":\"elitemobs-player-data\",\"version\":" + version
                + ",\"type\":\"" + type + "\",\"data\":" + data + "}").getBytes(StandardCharsets.UTF_8);
    }
}
