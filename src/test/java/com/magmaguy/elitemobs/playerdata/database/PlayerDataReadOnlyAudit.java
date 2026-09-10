package com.magmaguy.elitemobs.playerdata.database;

import com.google.gson.JsonParser;

import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.LinkedHashMap;
import java.util.Map;

/** Runs on the database host. No writes and no player identifiers or payloads in the output. */
public final class PlayerDataReadOnlyAudit {
    private static final String[] COLUMNS = {"QuestStatus", "PlayerQuestCooldowns", "DungeonBossLockouts", "QuestLockouts"};

    public static void main(String[] args) throws Exception {
        try (Connection db = DriverManager.getConnection(args[0], args[1], System.getenv("ELITEMOBS_AUDIT_PASSWORD"))) {
            db.setReadOnly(true);
            db.setAutoCommit(false);
            boolean passed = true;
            for (String table : new String[]{"PlayerData", "PlayerDataSerializedLegacy", "PlayerDataSerializedSnapshots"}) {
                try (ResultSet tables = db.getMetaData().getTables(db.getCatalog(), null, table, new String[]{"TABLE"})) {
                    if (!tables.next()) continue;
                }
                passed &= audit(db, table);
            }
            db.rollback();
            if (!passed) throw new IllegalStateException("Player-data audit failed; see aggregate counts above");
        }
    }

    private static boolean audit(Connection db, String table) throws Exception {
        int rows = 0;
        int[] present = new int[4], valid = new int[4], legacy = new int[4];
        Map<String, Integer> failures = new LinkedHashMap<>();
        try (Statement statement = db.createStatement(); ResultSet result = statement.executeQuery(
                "SELECT " + String.join(",", COLUMNS) + " FROM " + table)) {
            while (result.next()) {
                rows++;
                for (int i = 0; i < COLUMNS.length; i++) {
                    byte[] bytes = result.getBytes(i + 1);
                    if (bytes == null) continue;
                    present[i]++;
                    if (!PlayerDataJsonCodec.isJson(bytes)) legacy[i]++;
                    try {
                        byte[] json = roundTrip(i, bytes);
                        byte[] repeated = roundTrip(i, json);
                        if (!tree(json).equals(tree(repeated))) throw new IllegalStateException("Unstable round trip");
                        // For existing JSON, also prove the reader has not silently dropped saved fields.
                        if (PlayerDataJsonCodec.isJson(bytes) && !tree(bytes).equals(tree(json)))
                            throw new IllegalStateException("Stored JSON changed on round trip");
                        valid[i]++;
                    } catch (Exception failure) {
                        failures.merge(COLUMNS[i] + ":" + failure.getClass().getSimpleName(), 1, Integer::sum);
                    }
                }
            }
        }
        System.out.println(table + " rows=" + rows);
        for (int i = 0; i < COLUMNS.length; i++)
            System.out.println(COLUMNS[i] + " present=" + present[i] + " roundTripValid=" + valid[i] + " legacy=" + legacy[i]);
        System.out.println("failures=" + failures);
        return failures.isEmpty();
    }

    private static com.google.gson.JsonElement tree(byte[] bytes) {
        return JsonParser.parseString(new String(bytes, StandardCharsets.UTF_8));
    }

    private static byte[] roundTrip(int column, byte[] bytes) throws Exception {
        return switch (column) {
            case 0 -> PlayerDataJsonCodec.encodeQuests(PlayerDataJsonCodec.decodeQuests(bytes));
            case 1 -> PlayerDataJsonCodec.encodePlayerQuestCooldowns(PlayerDataJsonCodec.decodePlayerQuestCooldowns(bytes));
            case 2 -> PlayerDataJsonCodec.encodeDungeonBossLockout(PlayerDataJsonCodec.decodeDungeonBossLockout(bytes));
            case 3 -> PlayerDataJsonCodec.encodeQuestLockout(PlayerDataJsonCodec.decodeQuestLockout(bytes));
            default -> throw new IllegalArgumentException("Unknown column");
        };
    }
}
