package com.magmaguy.elitemobs.playerdata.database;

import com.magmaguy.elitemobs.dungeons.DungeonBossLockout;
import com.magmaguy.elitemobs.items.customloottable.CurrencyCustomLootEntry;
import com.magmaguy.elitemobs.quests.Quest;
import com.magmaguy.elitemobs.quests.QuestLockout;
import com.magmaguy.elitemobs.quests.objectives.DialogObjective;
import com.magmaguy.elitemobs.quests.objectives.QuestObjectives;
import com.magmaguy.elitemobs.quests.playercooldowns.PlayerQuestCooldowns;
import com.magmaguy.elitemobs.quests.rewards.QuestReward;
import com.magmaguy.elitemobs.utils.ObjectSerializer;
import org.bukkit.entity.Player;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Proxy;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertTrue;

class PlayerDataJsonCodecTest {

    @AfterEach
    void clearPendingQuests() {
        Quest.shutdown();
    }

    @Test
    void questGraphRoundTripsWithObjectiveTypeAndBackReference() throws Exception {
        UUID playerId = UUID.randomUUID();
        DialogObjective objective = new DialogObjective("guide.yml", "Guide", "world,1,2,3", List.of("Hello"));
        objective.setCurrentAmount(1);
        QuestObjectives objectives = new QuestObjectives(UUID.randomUUID(), List.of(objective));
        Player player = player(playerId);
        QuestReward reward = new QuestReward(17, objectives, player);
        objectives.setQuestReward(reward);
        Quest quest = new Quest(player, objectives, 17);
        quest.setAccepted(true);
        objectives.setQuest(quest);

        byte[] encoded = PlayerDataJsonCodec.encodeQuests(List.of(quest));
        List<Quest> decoded = PlayerDataJsonCodec.decodeQuests(encoded);

        assertTrue(new String(encoded, StandardCharsets.UTF_8).startsWith("{\"format\":\"elitemobs-player-data\""));
        assertEquals(1, decoded.size());
        assertEquals(quest.getQuestID(), decoded.getFirst().getQuestID());
        assertEquals(playerId, decoded.getFirst().getPlayerUUID());
        assertEquals(17, decoded.getFirst().getQuestLevel());
        DialogObjective decodedObjective = assertInstanceOf(DialogObjective.class,
                decoded.getFirst().getQuestObjectives().getObjectives().getFirst());
        assertEquals(1, decodedObjective.getCurrentAmount());
        assertEquals("guide.yml", decodedObjective.getNpcFilename());
        assertInstanceOf(CurrencyCustomLootEntry.class, decoded.getFirst().getQuestObjectives()
                .getQuestReward().getCustomLootTable().getEntries().getFirst());
        assertSame(decoded.getFirst(), decoded.getFirst().getQuestObjectives().getQuest());

        byte[] legacy = withMismatchedUid(ObjectSerializer.toString(new ArrayList<>(List.of(quest))), Quest.class);
        assertEquals(quest.getQuestID(), PlayerDataJsonCodec.decodeQuests(legacy).getFirst().getQuestID());

        // Historical versions can also have removed fields. Preserve the stream's own layout,
        // so an obsolete field is skipped without shifting the subsequent values or references.
        byte[] oldLayout = Base64.getDecoder().decode(legacy);
        byte[] fieldName = "questName".getBytes(StandardCharsets.UTF_8);
        int nameOffset = -1;
        for (int i = 0; i <= oldLayout.length - fieldName.length; i++) {
            if (java.util.Arrays.equals(oldLayout, i, i + fieldName.length, fieldName, 0, fieldName.length)) {
                nameOffset = i;
                break;
            }
        }
        assertTrue(nameOffset >= 0);
        System.arraycopy("extraName".getBytes(StandardCharsets.UTF_8), 0, oldLayout, nameOffset, fieldName.length);
        Quest oldQuest = PlayerDataJsonCodec.decodeQuests(Base64.getEncoder().encode(oldLayout)).getFirst();
        assertEquals(17, oldQuest.getQuestLevel());
        assertEquals(quest.getQuestID(), oldQuest.getQuestID());
        assertSame(oldQuest, oldQuest.getQuestObjectives().getQuest());
    }

    @Test
    void simplePlayerStateRoundTripsAndReadsLegacyJavaPayloads() throws Exception {
        DungeonBossLockout dungeonLockout = new DungeonBossLockout();
        dungeonLockout.getLockouts().put("boss.yml:1,2,3", Long.MAX_VALUE);
        QuestLockout questLockout = new QuestLockout();
        questLockout.getLockouts().put("quest.yml", Long.MAX_VALUE - 1);
        PlayerQuestCooldowns cooldowns = new PlayerQuestCooldowns();

        assertEquals(dungeonLockout.getLockouts(), PlayerDataJsonCodec.decodeDungeonBossLockout(
                PlayerDataJsonCodec.encodeDungeonBossLockout(dungeonLockout)).getLockouts());
        assertEquals(questLockout.getLockouts(), PlayerDataJsonCodec.decodeQuestLockout(
                PlayerDataJsonCodec.encodeQuestLockout(questLockout)).getLockouts());
        assertEquals(0, PlayerDataJsonCodec.decodePlayerQuestCooldowns(
                PlayerDataJsonCodec.encodePlayerQuestCooldowns(cooldowns)).getQuestCooldowns().size());

        byte[] legacy = ObjectSerializer.toString(dungeonLockout).getBytes(StandardCharsets.UTF_8);
        assertEquals(dungeonLockout.getLockouts(), PlayerDataJsonCodec.decodeDungeonBossLockout(legacy).getLockouts());
        byte[] legacyCooldowns = withMismatchedUid(ObjectSerializer.toString(cooldowns), PlayerQuestCooldowns.class);
        assertEquals(0, PlayerDataJsonCodec.decodePlayerQuestCooldowns(legacyCooldowns).getQuestCooldowns().size());
    }

    @Test
    void sqliteMigrationBatchesJsonWritesAndKeepsOriginalBytes() throws Exception {
        try (Connection connection = DriverManager.getConnection("jdbc:sqlite::memory:")) {
            try (Statement statement = connection.createStatement()) {
                statement.executeUpdate("CREATE TABLE PlayerData (PlayerUUID VARCHAR(36) PRIMARY KEY NOT NULL, "
                        + "QuestStatus MEDIUMBLOB, PlayerQuestCooldowns MEDIUMBLOB, "
                        + "DungeonBossLockouts MEDIUMBLOB, QuestLockouts MEDIUMBLOB)");
            }
            UUID playerId = UUID.randomUUID();
            DungeonBossLockout lockout = new DungeonBossLockout();
            lockout.getLockouts().put("boss.yml:4,5,6", Long.MAX_VALUE);
            byte[] legacy = ObjectSerializer.toString(lockout).getBytes(StandardCharsets.UTF_8);
            try (PreparedStatement insert = connection.prepareStatement(
                    "INSERT INTO PlayerData (PlayerUUID, DungeonBossLockouts) VALUES (?, ?)")) {
                insert.setString(1, playerId.toString());
                insert.setBytes(2, legacy);
                insert.executeUpdate();
            }

            SerializedPlayerDataMigration.migrate(connection);
            SerializedPlayerDataMigration.migrate(connection);

            try (PreparedStatement query = connection.prepareStatement(
                    "SELECT p.DungeonBossLockouts, b.DungeonBossLockouts "
                            + "FROM PlayerData p JOIN " + SerializedPlayerDataMigration.BACKUP_TABLE
                            + " b USING (PlayerUUID) WHERE p.PlayerUUID = ?")) {
                query.setString(1, playerId.toString());
                try (ResultSet resultSet = query.executeQuery()) {
                    assertTrue(resultSet.next());
                    byte[] json = resultSet.getBytes(1);
                    assertTrue(PlayerDataJsonCodec.isJson(json));
                    assertEquals(lockout.getLockouts(), PlayerDataJsonCodec.decodeDungeonBossLockout(json).getLockouts());
                    assertArrayEquals(legacy, resultSet.getBytes(2));
                }
            }
            try (Statement statement = connection.createStatement();
                 ResultSet resultSet = statement.executeQuery("SELECT COUNT(*) FROM "
                         + SerializedPlayerDataMigration.BACKUP_TABLE)) {
                assertTrue(resultSet.next());
                assertEquals(1, resultSet.getInt(1));
            }
        }
    }

    private static Player player(UUID playerId) {
        return (Player) Proxy.newProxyInstance(Player.class.getClassLoader(), new Class<?>[]{Player.class},
                (proxy, method, args) -> method.getName().equals("getUniqueId") ? playerId : null);
    }

    private static byte[] withMismatchedUid(String serialized, Class<?> type) {
        byte[] data = Base64.getDecoder().decode(serialized);
        byte[] name = type.getName().getBytes(StandardCharsets.UTF_8);
        for (int offset = 0; offset + name.length + 11 < data.length; offset++) {
            if (data[offset] != 0x72 || data[offset + 1] != (byte) (name.length >>> 8)
                    || data[offset + 2] != (byte) name.length) continue;
            boolean matches = true;
            for (int index = 0; index < name.length; index++)
                if (data[offset + 3 + index] != name[index]) matches = false;
            if (!matches) continue;
            int uidStart = offset + 3 + name.length;
            data[uidStart] ^= 1;
            return Base64.getEncoder().encode(data);
        }
        throw new AssertionError("Class descriptor not found for " + type.getName());
    }
}
