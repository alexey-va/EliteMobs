package com.magmaguy.elitemobs.playerdata.database;

import com.magmaguy.elitemobs.config.DatabaseConfig;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Field;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicBoolean;

import static org.junit.jupiter.api.Assertions.*;

class PersistenceFailureTest {
    private Connection db;
    private Map<String, DungeonRuntimeData.RuntimeWrite> queue;

    @BeforeEach
    @SuppressWarnings("unchecked")
    void setUp() throws Exception {
        db = PersistenceReviewTest.database();
        field(PlayerDataRepository.class, "connection").set(null, db);
        DatabaseConfig.mysqlRuntimeNamespace = "failure-test";
        DungeonRuntimeData.initializeSchema(db);
        // Exercise the shutdown flush without Bukkit's scheduler. The real queue, JDBC connection,
        // transaction, acknowledgment and retry paths are used unchanged.
        field(DungeonRuntimeData.class, "available").set(null, false);
        queue = (Map<String, DungeonRuntimeData.RuntimeWrite>) field(DungeonRuntimeData.class, "pendingWrites").get(null);
        queue.clear();
    }

    @AfterEach
    void tearDown() throws Exception {
        queue.clear();
        field(DungeonRuntimeData.class, "consecutiveWriteFailures").set(null, 0);
        field(PlayerDataRepository.class, "connection").set(null, null);
        db.close();
    }

    @Test
    void failedTransactionKeepsWritesAndRetryUsesLatestValue() throws Exception {
        AtomicBoolean fail = new AtomicBoolean(true);
        queue.put("first", write("first", 10));
        queue.put("second", new DungeonRuntimeData.RuntimeWrite("injected failure", connection -> {
            if (fail.getAndSet(false)) throw new SQLException("injected failure");
            write("second", 20).operation().execute(connection);
        }));

        assertFalse(DungeonRuntimeData.drainWrites());
        assertTrue(db.getAutoCommit());
        assertNull(value("first"));
        assertEquals(2, queue.size());
        queue.put("first", write("first", 30));

        assertTrue(DungeonRuntimeData.drainWrites());
        assertEquals(30, value("first"));
        assertEquals(20, value("second"));
        assertTrue(queue.isEmpty());
    }

    @Test
    void acknowledgeDoesNotRemoveAReplacementArrivingDuringJdbc() throws Exception {
        queue.put("first", new DungeonRuntimeData.RuntimeWrite("in-flight update", connection -> {
            write("first", 10).operation().execute(connection);
            queue.put("first", write("first", 30));
        }));
        assertTrue(DungeonRuntimeData.drainWrites());
        assertEquals(10, value("first"));
        assertEquals(1, queue.size());
        assertTrue(DungeonRuntimeData.drainWrites());
        assertEquals(30, value("first"));
        assertTrue(queue.isEmpty());
    }

    @Test
    void runtimeTransactionUsesJdbcLockWhilePlayerStateRemainsAvailable() throws Exception {
        CountDownLatch entered = new CountDownLatch(1);
        queue.put("first", new DungeonRuntimeData.RuntimeWrite("lock probe", connection -> entered.countDown()));
        try (var executor = Executors.newFixedThreadPool(2)) {
            java.util.concurrent.Future<Boolean> drain;
            synchronized (PlayerDataRepository.jdbcMonitor()) {
                drain = executor.submit(DungeonRuntimeData::drainWrites);
                assertFalse(entered.await(150, TimeUnit.MILLISECONDS), "runtime SQL bypassed the connection lock");
                executor.submit(() -> { synchronized (PlayerDataRepository.stateMonitor()) { } }).get(1, TimeUnit.SECONDS);
            }
            assertTrue(drain.get(2, TimeUnit.SECONDS));
            assertEquals(0, entered.getCount());
        }
    }

    @Test
    void malformedQuestDataCannotBeReadAsEmptyAndThenOverwritten() throws Exception {
        UUID player = UUID.randomUUID();
        byte[] malformed = "{broken-json".getBytes(java.nio.charset.StandardCharsets.UTF_8);
        try (PreparedStatement insert = db.prepareStatement("INSERT INTO PlayerData (PlayerUUID, QuestStatus) VALUES (?, ?)")) {
            insert.setString(1, player.toString());
            insert.setBytes(2, malformed);
            insert.executeUpdate();
        }
        assertThrows(IllegalStateException.class, () -> PlayerData.getQuests(player));
        assertThrows(IllegalStateException.class, () -> PlayerData.updateQuestStatus(player));
        assertArrayEquals(malformed, (byte[]) PlayerDataRepository.getBlob(player, "QuestStatus"));
        assertFalse(PlayerData.isDataLoaded(player));
    }

    @Test
    void missingStateIsEmptyButSqlErrorsPropagate() throws Exception {
        UUID player = UUID.randomUUID();
        assertTrue(PlayerData.getQuests(player).isEmpty());
        assertTrue(PlayerData.getQuestLockout(player).getLockouts().isEmpty());
        try (var statement = db.createStatement()) {
            statement.executeUpdate("DROP TABLE PlayerData");
        }
        assertThrows(IllegalStateException.class, () -> PlayerData.getQuests(player));
        assertThrows(IllegalStateException.class, () -> PlayerData.getQuestLockout(player));
    }

    private DungeonRuntimeData.RuntimeWrite write(String key, long value) {
        return new DungeonRuntimeData.RuntimeWrite(key, connection -> DungeonRuntimeData.upsertCooldown(connection,
                DungeonRuntimeData.REGIONAL_BOSS_TABLE, "RespawnAt", key, "world,1,2,3", value));
    }

    private Long value(String key) throws Exception {
        return DungeonRuntimeData.readCooldown(db, DungeonRuntimeData.REGIONAL_BOSS_TABLE,
                "RespawnAt", key, "world,1,2,3");
    }

    private static Field field(Class<?> owner, String name) throws Exception {
        Field field = owner.getDeclaredField(name);
        field.setAccessible(true);
        return field;
    }
}
