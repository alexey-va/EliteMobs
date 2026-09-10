package com.magmaguy.elitemobs.playerdata.database;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.ExclusionStrategy;
import com.google.gson.FieldAttributes;
import com.google.gson.JsonArray;
import com.google.gson.JsonDeserializationContext;
import com.google.gson.JsonDeserializer;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParseException;
import com.google.gson.JsonParser;
import com.google.gson.JsonSerializationContext;
import com.google.gson.JsonSerializer;
import com.google.gson.reflect.TypeToken;
import com.magmaguy.elitemobs.dungeons.DungeonBossLockout;
import com.magmaguy.elitemobs.items.customloottable.CommandLootTable;
import com.magmaguy.elitemobs.items.customloottable.CurrencyCustomLootEntry;
import com.magmaguy.elitemobs.items.customloottable.CustomLootEntry;
import com.magmaguy.elitemobs.items.customloottable.EliteCustomLootEntry;
import com.magmaguy.elitemobs.items.customloottable.ItemStackCustomLootEntry;
import com.magmaguy.elitemobs.items.customloottable.VanillaCustomLootEntry;
import com.magmaguy.elitemobs.quests.CustomQuest;
import com.magmaguy.elitemobs.quests.DynamicQuest;
import com.magmaguy.elitemobs.quests.Quest;
import com.magmaguy.elitemobs.quests.QuestLockout;
import com.magmaguy.elitemobs.quests.objectives.ArenaObjective;
import com.magmaguy.elitemobs.quests.objectives.CustomFetchObjective;
import com.magmaguy.elitemobs.quests.objectives.CustomKillObjective;
import com.magmaguy.elitemobs.quests.objectives.DialogObjective;
import com.magmaguy.elitemobs.quests.objectives.DynamicKillObjective;
import com.magmaguy.elitemobs.quests.objectives.Objective;
import com.magmaguy.elitemobs.quests.objectives.QuestObjectives;
import com.magmaguy.elitemobs.quests.playercooldowns.PlayerQuestCooldowns;
import com.magmaguy.elitemobs.utils.ObjectSerializer;

import java.lang.reflect.Type;
import java.lang.reflect.Field;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/** Versioned JSON codec for the four structured player-data BLOB columns. */
final class PlayerDataJsonCodec {

    private static final String FORMAT = "elitemobs-player-data";
    private static final int VERSION = 1;
    private static final Gson RAW_GSON = new GsonBuilder().disableHtmlEscaping().create();
    private static final PolymorphicAdapter<Objective> OBJECTIVE_ADAPTER = new PolymorphicAdapter<>(RAW_GSON,
            Map.of("custom-fetch", CustomFetchObjective.class,
                    "custom-kill", CustomKillObjective.class,
                    "dynamic-kill", DynamicKillObjective.class,
                    "dialog", DialogObjective.class,
                    "arena", ArenaObjective.class));
    private static final PolymorphicAdapter<CustomLootEntry> LOOT_ENTRY_ADAPTER = new PolymorphicAdapter<>(RAW_GSON,
            Map.of("currency", CurrencyCustomLootEntry.class,
                    "vanilla", VanillaCustomLootEntry.class,
                    "elite", EliteCustomLootEntry.class,
                    "command", CommandLootTable.class,
                    "item-stack", ItemStackCustomLootEntry.class));
    private static final Gson QUEST_GSON = new GsonBuilder()
            .disableHtmlEscaping()
            .addSerializationExclusionStrategy(new QuestBackReferenceExclusion())
            .addDeserializationExclusionStrategy(new QuestBackReferenceExclusion())
            .registerTypeHierarchyAdapter(Objective.class, OBJECTIVE_ADAPTER)
            .registerTypeHierarchyAdapter(CustomLootEntry.class, LOOT_ENTRY_ADAPTER)
            .create();
    private static final QuestAdapter QUEST_ADAPTER = new QuestAdapter();
    private static final Field QUEST_REFERENCE_FIELD = questReferenceField();
    private static final Type COOLDOWNS_TYPE = new TypeToken<PlayerQuestCooldowns>() { }.getType();

    private PlayerDataJsonCodec() {
    }

    static byte[] encodeQuests(List<Quest> quests) {
        JsonArray data = new JsonArray();
        for (Quest quest : quests) data.add(QUEST_ADAPTER.serialize(quest, Quest.class, null));
        return envelope("quest-list", data);
    }

    static List<Quest> decodeQuests(byte[] bytes) throws Exception {
        if (!isJson(bytes)) return castLegacyList(decodeLegacy(bytes));
        JsonArray data = payload(bytes, "quest-list").getAsJsonArray();
        List<Quest> quests = new ArrayList<>();
        for (JsonElement element : data)
            quests.add(QUEST_ADAPTER.deserialize(element, Quest.class, null));
        return quests;
    }

    static byte[] encodePlayerQuestCooldowns(PlayerQuestCooldowns cooldowns) {
        return envelope("quest-cooldowns", RAW_GSON.toJsonTree(cooldowns, COOLDOWNS_TYPE));
    }

    static PlayerQuestCooldowns decodePlayerQuestCooldowns(byte[] bytes) throws Exception {
        if (!isJson(bytes)) return (PlayerQuestCooldowns) decodeLegacy(bytes);
        return RAW_GSON.fromJson(payload(bytes, "quest-cooldowns"), COOLDOWNS_TYPE);
    }

    static byte[] encodeDungeonBossLockout(DungeonBossLockout lockout) {
        return envelope("dungeon-boss-lockouts", RAW_GSON.toJsonTree(lockout));
    }

    static DungeonBossLockout decodeDungeonBossLockout(byte[] bytes) throws Exception {
        if (!isJson(bytes)) return (DungeonBossLockout) decodeLegacy(bytes);
        return RAW_GSON.fromJson(payload(bytes, "dungeon-boss-lockouts"), DungeonBossLockout.class);
    }

    static byte[] encodeQuestLockout(QuestLockout lockout) {
        return envelope("quest-lockouts", RAW_GSON.toJsonTree(lockout));
    }

    static QuestLockout decodeQuestLockout(byte[] bytes) throws Exception {
        if (!isJson(bytes)) return (QuestLockout) decodeLegacy(bytes);
        return RAW_GSON.fromJson(payload(bytes, "quest-lockouts"), QuestLockout.class);
    }

    static boolean isJson(byte[] bytes) {
        if (bytes == null) return false;
        for (byte value : bytes) {
            if (Character.isWhitespace(value)) continue;
            return value == '{';
        }
        return false;
    }

    private static byte[] envelope(String type, JsonElement data) {
        JsonObject envelope = new JsonObject();
        envelope.addProperty("format", FORMAT);
        envelope.addProperty("version", VERSION);
        envelope.addProperty("type", type);
        envelope.add("data", data);
        return RAW_GSON.toJson(envelope).getBytes(StandardCharsets.UTF_8);
    }

    private static JsonElement payload(byte[] bytes, String expectedType) {
        JsonObject envelope = JsonParser.parseString(new String(bytes, StandardCharsets.UTF_8)).getAsJsonObject();
        if (!FORMAT.equals(envelope.get("format").getAsString()))
            throw new JsonParseException("Unknown player-data JSON format");
        if (envelope.get("version").getAsInt() != VERSION)
            throw new JsonParseException("Unsupported player-data JSON version " + envelope.get("version"));
        if (!expectedType.equals(envelope.get("type").getAsString()))
            throw new JsonParseException("Expected " + expectedType + " player data");
        return envelope.get("data");
    }

    private static Object decodeLegacy(byte[] bytes) throws Exception {
        return ObjectSerializer.fromString(new String(bytes, StandardCharsets.UTF_8));
    }

    private static List<Quest> castLegacyList(Object decoded) {
        if (!(decoded instanceof List<?> list)) throw new JsonParseException("Legacy quest data is not a list");
        List<Quest> quests = new ArrayList<>();
        for (Object entry : list) {
            if (!(entry instanceof Quest quest)) throw new JsonParseException("Legacy quest list contains an invalid value");
            quests.add(quest);
        }
        return quests;
    }

    private static final class QuestAdapter implements JsonSerializer<Quest>, JsonDeserializer<Quest> {
        private static final Map<String, Class<? extends Quest>> TYPES = Map.of(
                "quest", Quest.class,
                "custom", CustomQuest.class,
                "dynamic", DynamicQuest.class);

        @Override
        public JsonElement serialize(Quest source, Type type, JsonSerializationContext context) {
            JsonObject wrapper = new JsonObject();
            wrapper.addProperty("type", typeName(source.getClass(), TYPES));
            wrapper.add("value", QUEST_GSON.toJsonTree(source, source.getClass()));
            return wrapper;
        }

        @Override
        public Quest deserialize(JsonElement json, Type type, JsonDeserializationContext context) {
            JsonObject wrapper = json.getAsJsonObject();
            Class<? extends Quest> concrete = TYPES.get(wrapper.get("type").getAsString());
            if (concrete == null) throw new JsonParseException("Unknown quest type");
            Quest quest = QUEST_GSON.fromJson(wrapper.get("value"), concrete);
            restoreQuestReference(quest);
            return quest;
        }
    }

    private static void restoreQuestReference(Quest quest) {
        if (quest.getQuestObjectives() == null) return;
        try {
            QUEST_REFERENCE_FIELD.set(quest.getQuestObjectives(), quest);
        } catch (IllegalAccessException exception) {
            throw new JsonParseException("Could not restore quest objective back-reference", exception);
        }
    }

    private static Field questReferenceField() {
        try {
            Field field = QuestObjectives.class.getDeclaredField("quest");
            field.setAccessible(true);
            return field;
        } catch (NoSuchFieldException exception) {
            throw new ExceptionInInitializerError(exception);
        }
    }

    private static final class QuestBackReferenceExclusion implements ExclusionStrategy {
        @Override
        public boolean shouldSkipField(FieldAttributes field) {
            return field.getDeclaringClass() == QuestObjectives.class && field.getName().equals("quest");
        }

        @Override
        public boolean shouldSkipClass(Class<?> type) {
            return false;
        }
    }

    private static final class PolymorphicAdapter<T> implements JsonSerializer<T>, JsonDeserializer<T> {
        private final Gson gson;
        private final Map<String, Class<? extends T>> types;

        private PolymorphicAdapter(Gson gson, Map<String, Class<? extends T>> types) {
            this.gson = gson;
            this.types = new LinkedHashMap<>(types);
        }

        @Override
        public JsonElement serialize(T source, Type type, JsonSerializationContext context) {
            JsonObject wrapper = new JsonObject();
            wrapper.addProperty("type", typeName(source.getClass(), types));
            wrapper.add("value", gson.toJsonTree(source, source.getClass()));
            return wrapper;
        }

        @Override
        public T deserialize(JsonElement json, Type type, JsonDeserializationContext context) {
            JsonObject wrapper = json.getAsJsonObject();
            Class<? extends T> concrete = types.get(wrapper.get("type").getAsString());
            if (concrete == null) throw new JsonParseException("Unknown polymorphic player-data type");
            return gson.fromJson(wrapper.get("value"), concrete);
        }
    }

    private static <T> String typeName(Class<?> concrete, Map<String, Class<? extends T>> types) {
        for (Map.Entry<String, Class<? extends T>> entry : types.entrySet())
            if (entry.getValue().equals(concrete)) return entry.getKey();
        throw new JsonParseException("Unsupported player-data class " + concrete.getName());
    }
}
