package com.magmaguy.elitemobs.playerdata.database;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.magmaguy.elitemobs.dungeons.DungeonBossLockout;
import com.magmaguy.elitemobs.quests.Quest;
import com.magmaguy.elitemobs.quests.QuestLockout;
import com.magmaguy.elitemobs.quests.playercooldowns.PlayerQuestCooldowns;
import com.magmaguy.elitemobs.utils.ObjectSerializer;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;
import java.io.Serializable;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.List;
import java.util.UUID;

/** Real domain objects hydrated from synthetic data; no server, clocks or random IDs. */
public final class SerializationFixtures {
    private static final Gson GSON = new Gson();
    private static final long BASE_TIME = 1_900_000_000_000L;
    private static final UUID PLAYER_ID = UUID.fromString("00000000-0000-4000-8000-000000000001");

    private SerializationFixtures() { }

    public enum Profile { EMPTY, TYPICAL, HEAVY }
    public enum Format { JSON, JAVA_BASE64, JAVA_RAW }

    public record Snapshot(List<Quest> quests, PlayerQuestCooldowns cooldowns,
                           DungeonBossLockout dungeonLockouts, QuestLockout questLockouts) { }

    public static Snapshot create(Profile profile) {
        int[] counts = switch (profile) {
            case EMPTY -> new int[]{0, 0, 0, 0};
            case TYPICAL -> new int[]{5, 16, 32, 64};
            case HEAVY -> new int[]{30, 128, 256, 512};
        };
        JsonArray quests = new JsonArray();
        for (int i = 0; i < counts[0]; i++) quests.add(quest(i));
        JsonArray cooldowns = new JsonArray();
        for (int i = 0; i < counts[1]; i++)
            cooldowns.add(object("permission", "elite.quest.cooldown." + i + ".пропуск",
                    "permanent", i % 9 == 0, "targetUnixTime", i % 9 == 0 ? 0 : BASE_TIME + i * 300_000L));
        DungeonBossLockout dungeon = new DungeonBossLockout();
        for (int i = 0; i < counts[2]; i++)
            dungeon.getLockouts().put("подземелье-" + (i % 11) + ".yml:" + i + ",78," + (i + 2),
                    BASE_TIME + i * 60_000L);
        QuestLockout lockouts = new QuestLockout();
        for (int i = 0; i < counts[3]; i++)
            lockouts.getLockouts().put("quests/квест-" + i + ".yml", BASE_TIME + i * 120_000L);
        try {
            // Hydration bypasses gameplay constructors with scheduler/config side effects.
            // It runs only during setup; tests also assert independent known fixture values.
            return new Snapshot(PlayerDataJsonCodec.decodeQuests(envelope("quest-list", quests)),
                    PlayerDataJsonCodec.decodePlayerQuestCooldowns(envelope("quest-cooldowns",
                            object("questCooldowns", cooldowns))), dungeon, lockouts);
        } catch (Exception exception) {
            throw new AssertionError("Invalid synthetic player fixture", exception);
        }
    }

    private static JsonObject quest(int index) {
        String kind = switch (index % 3) { case 1 -> "custom"; case 2 -> "dynamic"; default -> "quest"; };
        int level = 4 + index % 13;
        JsonArray objectives = new JsonArray();
        if (kind.equals("dynamic")) {
            objectives.add(objective("dynamic-kill", 4 + index % 6, index % 3,
                    object("entityType", "ZOMBIE", "minMobLevel", level)));
        } else {
            objectives.add(objective("dialog", 1, index % 2,
                    object("npcFilename", "guide-" + index + ".yml", "targetLocation", "world,10,64,20",
                            "dialog", List.of("Слушай внимательно, странник №" + index + ".", "出口在东方."))));
            objectives.add(objective("custom-fetch", 3, index % 4,
                    object("key", "items/лазурный-осколок.yml", "readyToPickUp", true, "requireItemTurnIn", true)));
            objectives.add(objective("custom-kill", 5, index % 5,
                    object("customBossFilename", "bosses/страж-" + index + ".yml")));
        }
        JsonObject reward = object("rewardLevel", level, "playerUUID", PLAYER_ID.toString(),
                "generateProceduralReward", kind.equals("dynamic"),
                "customLootTable", object("entries", List.of(
                        object("type", "currency", "value", object("currencyAmount", 75 + index,
                                "chance", 0.75, "amount", 2, "permission", "reward.fixture", "wave", -1, "itemLevel", level)),
                        object("type", "vanilla", "value", object("material", "GOLD_INGOT",
                                "chance", 0.875, "amount", 1 + index % 3, "permission", "", "wave", -1, "itemLevel", level))),
                        "waveRewards", new JsonObject()));
        JsonObject value = object("questID", uuid("quest", index), "playerUUID", PLAYER_ID.toString(),
                "questName", "Контракт №" + index + " — древние руины 大陸", "questLevel", level,
                "questGiver", "giver-" + index + ".yml", "questTaker", "taker-" + index + ".yml", "accepted", true,
                "questObjectives", object("uuid", uuid("objectives", index), "objectives", objectives,
                        "questReward", reward, "over", false, "turnedIn", false, "forceOver", false));
        if (kind.equals("custom")) value.addProperty("configurationFilename", "quests/контракт-" + index + ".yml");
        return object("type", kind, "value", value);
    }

    private static JsonObject objective(String type, int target, int current, JsonObject fields) {
        fields.addProperty("targetAmount", target);
        fields.addProperty("currentAmount", current);
        fields.addProperty("objectiveCompleted", current >= target);
        fields.addProperty("objectiveName", "Цель — " + type);
        return object("type", type, "value", fields);
    }

    private static JsonObject object(Object... fields) {
        JsonObject object = new JsonObject();
        for (int i = 0; i < fields.length; i += 2)
            object.add((String) fields[i], GSON.toJsonTree(fields[i + 1]));
        return object;
    }

    private static byte[] envelope(String type, Object data) {
        return object("format", "elitemobs-player-data", "version", 1, "type", type, "data", data)
                .toString().getBytes(StandardCharsets.UTF_8);
    }

    private static String uuid(String kind, int index) {
        return UUID.nameUUIDFromBytes((kind + ":" + index).getBytes(StandardCharsets.UTF_8)).toString();
    }

    /** Each column uses a new stream/document, as it does in the persistence layer. */
    public static byte[][] encode(Snapshot snapshot, Format format) {
        try {
            return switch (format) {
                case JSON -> new byte[][]{
                        PlayerDataJsonCodec.encodeQuests(snapshot.quests()),
                        PlayerDataJsonCodec.encodePlayerQuestCooldowns(snapshot.cooldowns()),
                        PlayerDataJsonCodec.encodeDungeonBossLockout(snapshot.dungeonLockouts()),
                        PlayerDataJsonCodec.encodeQuestLockout(snapshot.questLockouts())};
                case JAVA_BASE64, JAVA_RAW -> new byte[][]{
                        writeJava((Serializable) snapshot.quests(), format), writeJava(snapshot.cooldowns(), format),
                        writeJava(snapshot.dungeonLockouts(), format), writeJava(snapshot.questLockouts(), format)};
            };
        } catch (Exception exception) {
            throw new IllegalStateException("Could not encode fixture", exception);
        }
    }

    @SuppressWarnings("unchecked")
    public static Snapshot decode(byte[][] columns, Format format) {
        try {
            return switch (format) {
                case JSON -> new Snapshot(PlayerDataJsonCodec.decodeQuests(columns[0]),
                        PlayerDataJsonCodec.decodePlayerQuestCooldowns(columns[1]),
                        PlayerDataJsonCodec.decodeDungeonBossLockout(columns[2]),
                        PlayerDataJsonCodec.decodeQuestLockout(columns[3]));
                case JAVA_BASE64, JAVA_RAW -> new Snapshot((List<Quest>) readJava(columns[0], format),
                        (PlayerQuestCooldowns) readJava(columns[1], format),
                        (DungeonBossLockout) readJava(columns[2], format), (QuestLockout) readJava(columns[3], format));
            };
        } catch (Exception exception) {
            throw new IllegalStateException("Could not decode fixture", exception);
        }
    }

    private static byte[] writeJava(Serializable value, Format format) throws Exception {
        if (format == Format.JAVA_BASE64)
            return ObjectSerializer.toString(value).getBytes(StandardCharsets.UTF_8);
        ByteArrayOutputStream bytes = new ByteArrayOutputStream();
        try (ObjectOutputStream output = new ObjectOutputStream(bytes)) {
            output.writeObject(value);
        }
        return bytes.toByteArray();
    }

    private static Object readJava(byte[] bytes, Format format) throws Exception {
        // Exact former upstream reader, without the new migration UID repair/filter.
        // Test-only: input comes exclusively from the synthetic fixtures above.
        byte[] payload = format == Format.JAVA_BASE64
                ? Base64.getDecoder().decode(new String(bytes, StandardCharsets.UTF_8)) : bytes;
        try (ObjectInputStream input = new ObjectInputStream(new ByteArrayInputStream(payload))) {
            return input.readObject();
        }
    }
}
