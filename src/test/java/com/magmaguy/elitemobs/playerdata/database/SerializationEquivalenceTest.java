package com.magmaguy.elitemobs.playerdata.database;

import com.magmaguy.elitemobs.items.customloottable.CurrencyCustomLootEntry;
import com.magmaguy.elitemobs.items.customloottable.CustomLootEntry;
import com.magmaguy.elitemobs.items.customloottable.VanillaCustomLootEntry;
import com.magmaguy.elitemobs.quests.CustomQuest;
import com.magmaguy.elitemobs.quests.DynamicQuest;
import com.magmaguy.elitemobs.quests.Quest;
import com.magmaguy.elitemobs.quests.objectives.CustomFetchObjective;
import com.magmaguy.elitemobs.quests.objectives.CustomKillObjective;
import com.magmaguy.elitemobs.quests.objectives.DialogObjective;
import com.magmaguy.elitemobs.quests.objectives.DynamicKillObjective;
import com.magmaguy.elitemobs.quests.objectives.Objective;
import com.magmaguy.elitemobs.quests.playercooldowns.PlayerQuestCooldowns;
import com.magmaguy.elitemobs.quests.playercooldowns.QuestCooldown;
import com.magmaguy.elitemobs.quests.rewards.QuestReward;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.Arguments;
import org.junit.jupiter.params.provider.MethodSource;
import org.junit.jupiter.params.provider.EnumSource;

import java.lang.reflect.Field;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Stream;

import static org.junit.jupiter.api.Assertions.assertArrayEquals;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertInstanceOf;
import static org.junit.jupiter.api.Assertions.assertNotSame;
import static org.junit.jupiter.api.Assertions.assertSame;
import static org.junit.jupiter.api.Assertions.assertTrue;

class SerializationEquivalenceTest {

    @ParameterizedTest(name = "{0}/{1}")
    @MethodSource("profilesAndFormats")
    void allFormatsPreserveTheFourColumnSemantics(SerializationFixtures.Profile profile,
                                                    SerializationFixtures.Format format) {
        SerializationFixtures.Snapshot expected = SerializationFixtures.create(profile);
        SerializationFixtures.Snapshot actual = SerializationFixtures.decode(
                SerializationFixtures.encode(expected, format), format);

        assertSnapshotEquals(expected, actual);
    }

    @ParameterizedTest
    @EnumSource(SerializationFixtures.Profile.class)
    void productionReaderDecodesTheOriginalJavaBase64Storage(SerializationFixtures.Profile profile) throws Exception {
        SerializationFixtures.Snapshot expected = SerializationFixtures.create(profile);
        byte[][] columns = SerializationFixtures.encode(expected, SerializationFixtures.Format.JAVA_BASE64);

        var decodedQuests = PlayerDataJsonCodec.decodeQuests(columns[0]);
        assertEquals(expected.quests().size(), decodedQuests.size());
        for (int index = 0; index < expected.quests().size(); index++)
            assertQuestEquals(expected.quests().get(index), decodedQuests.get(index));
        assertCooldownsEquals(expected.cooldowns(), PlayerDataJsonCodec.decodePlayerQuestCooldowns(columns[1]));
        assertEquals(expected.dungeonLockouts().getLockouts(),
                PlayerDataJsonCodec.decodeDungeonBossLockout(columns[2]).getLockouts());
        assertEquals(expected.questLockouts().getLockouts(),
                PlayerDataJsonCodec.decodeQuestLockout(columns[3]).getLockouts());
    }

    @ParameterizedTest
    @MethodSource("profilesAndFormats")
    void repeatedDecodeReturnsFreshGraphs(SerializationFixtures.Profile profile,
                                          SerializationFixtures.Format format) {
        SerializationFixtures.Snapshot expected = SerializationFixtures.create(profile);
        byte[][] columns = SerializationFixtures.encode(expected, format);
        byte[][] originalColumns = Arrays.stream(columns).map(byte[]::clone).toArray(byte[][]::new);
        SerializationFixtures.Snapshot first = SerializationFixtures.decode(columns, format);
        SerializationFixtures.Snapshot second = SerializationFixtures.decode(columns, format);

        assertNotSame(first, second);
        assertNotSame(first.quests(), second.quests());
        assertNotSame(first.cooldowns(), second.cooldowns());
        assertNotSame(first.dungeonLockouts(), second.dungeonLockouts());
        assertNotSame(first.questLockouts(), second.questLockouts());
        if (!first.quests().isEmpty()) {
            assertNotSame(first.quests().getFirst(), second.quests().getFirst());
            assertNotSame(first.quests().getFirst().getQuestObjectives(), second.quests().getFirst().getQuestObjectives());
            assertNotSame(first.quests().getFirst().getQuestObjectives().getObjectives().getFirst(),
                    second.quests().getFirst().getQuestObjectives().getObjectives().getFirst());
            first.quests().getFirst().getQuestObjectives().getObjectives().getFirst().setCurrentAmount(99);
            assertEquals(expected.quests().getFirst().getQuestObjectives().getObjectives().getFirst().getCurrentAmount(),
                    second.quests().getFirst().getQuestObjectives().getObjectives().getFirst().getCurrentAmount());
            first.quests().clear();
            assertEquals(expected.quests().size(), second.quests().size());
        }
        first.dungeonLockouts().getLockouts().clear();
        assertEquals(expected.dungeonLockouts().getLockouts().size(), second.dungeonLockouts().getLockouts().size());
        first.questLockouts().getLockouts().clear();
        assertEquals(expected.questLockouts().getLockouts().size(), second.questLockouts().getLockouts().size());
        if (!second.cooldowns().getQuestCooldowns().isEmpty()) {
            QuestCooldown original = second.cooldowns().getQuestCooldowns().getFirst();
            assertNotSame(original, first.cooldowns().getQuestCooldowns().getFirst());
            first.cooldowns().getQuestCooldowns().clear();
            assertEquals(expected.cooldowns().getQuestCooldowns().size(), second.cooldowns().getQuestCooldowns().size());
        }
        for (int index = 0; index < columns.length; index++)
            assertArrayEquals(originalColumns[index], columns[index]);
    }

    @ParameterizedTest(name = "{0}")
    @MethodSource("profileShapes")
    void profilesHaveTheRequestedShapeAndOnePlayerIdentity(SerializationFixtures.Profile profile,
                                                            int quests, int cooldowns,
                                                            int dungeonLockouts, int questLockouts) {
        SerializationFixtures.Snapshot snapshot = SerializationFixtures.create(profile);
        assertEquals(quests, snapshot.quests().size());
        assertEquals(cooldowns, snapshot.cooldowns().getQuestCooldowns().size());
        assertEquals(dungeonLockouts, snapshot.dungeonLockouts().getLockouts().size());
        assertEquals(questLockouts, snapshot.questLockouts().getLockouts().size());
        Set<UUID> playerIds = new HashSet<>();
        snapshot.quests().forEach(quest -> playerIds.add(quest.getPlayerUUID()));
        assertEquals(quests == 0 ? 0 : 1, playerIds.size());
    }

    @ParameterizedTest
    @EnumSource(value = SerializationFixtures.Profile.class, names = {"TYPICAL", "HEAVY"})
    void hydratedFixturesContainKnownDataIndependentlyOfTheRoundTrip(SerializationFixtures.Profile profile) {
        var snapshot = SerializationFixtures.create(profile);
        Quest first = snapshot.quests().getFirst();
        assertEquals("Контракт №0 — древние руины 大陸", first.getQuestName());
        assertEquals(4, first.getQuestLevel());
        assertEquals(UUID.fromString("00000000-0000-4000-8000-000000000001"), first.getPlayerUUID());
        assertTrue(first.isAccepted());
        assertEquals(3, first.getQuestObjectives().getObjectives().size());
        DialogObjective dialog = assertInstanceOf(DialogObjective.class,
                first.getQuestObjectives().getObjectives().getFirst());
        assertEquals("guide-0.yml", dialog.getNpcFilename());
        assertEquals("出口在东方.", dialog.getDialog().get(1));
        assertEquals(0, dialog.getCurrentAmount());
        CurrencyCustomLootEntry currency = assertInstanceOf(CurrencyCustomLootEntry.class,
                first.getQuestObjectives().getQuestReward().getCustomLootTable().getEntries().getFirst());
        assertEquals(75, currency.getCurrencyAmount());
        assertEquals(0.75, currency.getChance());
        assertEquals("quests/контракт-1.yml", assertInstanceOf(CustomQuest.class,
                snapshot.quests().get(1)).getConfigurationFilename());
        DynamicQuest dynamic = assertInstanceOf(DynamicQuest.class, snapshot.quests().get(2));
        DynamicKillObjective kill = assertInstanceOf(DynamicKillObjective.class,
                dynamic.getQuestObjectives().getObjectives().getFirst());
        assertEquals(6, kill.getTargetAmount());
        assertEquals(2, kill.getCurrentAmount());
        assertEquals(1_900_000_300_000L, snapshot.cooldowns().getQuestCooldowns().get(1).getTargetUnixTime());
        assertEquals(1_900_000_000_000L, snapshot.dungeonLockouts().getLockouts().get("подземелье-0.yml:0,78,2"));
        assertEquals(1_900_000_120_000L, snapshot.questLockouts().getLockouts().get("quests/квест-1.yml"));
    }

    @ParameterizedTest
    @EnumSource(SerializationFixtures.Profile.class)
    void createIsDeterministic(SerializationFixtures.Profile profile) {
        SerializationFixtures.Snapshot first = SerializationFixtures.create(profile);
        SerializationFixtures.Snapshot second = SerializationFixtures.create(profile);
        for (SerializationFixtures.Format format : SerializationFixtures.Format.values()) {
            byte[][] firstBytes = SerializationFixtures.encode(first, format);
            byte[][] secondBytes = SerializationFixtures.encode(second, format);
            assertEquals(firstBytes.length, secondBytes.length);
            for (int index = 0; index < firstBytes.length; index++)
                assertArrayEquals(firstBytes[index], secondBytes[index], format + " column " + index);
        }
    }

    static Stream<Arguments> profilesAndFormats() {
        return Stream.of(SerializationFixtures.Profile.values())
                .flatMap(profile -> Stream.of(SerializationFixtures.Format.values())
                        .map(format -> Arguments.of(profile, format)));
    }

    static Stream<Arguments> profileShapes() {
        return Stream.of(
                org.junit.jupiter.params.provider.Arguments.of(SerializationFixtures.Profile.EMPTY, 0, 0, 0, 0),
                org.junit.jupiter.params.provider.Arguments.of(SerializationFixtures.Profile.TYPICAL, 5, 16, 32, 64),
                org.junit.jupiter.params.provider.Arguments.of(SerializationFixtures.Profile.HEAVY, 30, 128, 256, 512));
    }

    private static void assertSnapshotEquals(SerializationFixtures.Snapshot expected,
                                             SerializationFixtures.Snapshot actual) {
        assertEquals(expected.quests().size(), actual.quests().size());
        for (int index = 0; index < expected.quests().size(); index++)
            assertQuestEquals(expected.quests().get(index), actual.quests().get(index));

        assertCooldownsEquals(expected.cooldowns(), actual.cooldowns());
        assertEquals(expected.dungeonLockouts().getLockouts(), actual.dungeonLockouts().getLockouts());
        assertEquals(expected.questLockouts().getLockouts(), actual.questLockouts().getLockouts());
    }

    private static void assertQuestEquals(Quest expected, Quest actual) {
        assertEquals(expected.getClass(), actual.getClass());
        assertEquals(expected.getQuestID(), actual.getQuestID());
        assertEquals(expected.getQuestName(), actual.getQuestName());
        assertEquals(expected.getQuestGiver(), actual.getQuestGiver());
        assertEquals(expected.getQuestTaker(), actual.getQuestTaker());
        assertEquals(expected.getPlayerUUID(), actual.getPlayerUUID());
        assertEquals(expected.getQuestLevel(), actual.getQuestLevel());
        assertEquals(expected.isAccepted(), actual.isAccepted());
        if (expected instanceof CustomQuest expectedCustom)
            assertEquals(expectedCustom.getConfigurationFilename(), ((CustomQuest) actual).getConfigurationFilename());
        assertEquals(expected.getQuestObjectives().getUuid(), actual.getQuestObjectives().getUuid());
        assertEquals(expected.getQuestObjectives().isTurnedIn(), actual.getQuestObjectives().isTurnedIn());
        assertEquals(expected.getQuestObjectives().getObjectives().size(), actual.getQuestObjectives().getObjectives().size());
        for (int index = 0; index < expected.getQuestObjectives().getObjectives().size(); index++)
            assertObjectiveEquals(expected.getQuestObjectives().getObjectives().get(index),
                    actual.getQuestObjectives().getObjectives().get(index));
        assertRewardEquals(expected.getQuestObjectives().getQuestReward(), actual.getQuestObjectives().getQuestReward());
        assertSame(actual, actual.getQuestObjectives().getQuest());
    }

    private static void assertObjectiveEquals(Objective expected, Objective actual) {
        assertEquals(expected.getClass(), actual.getClass());
        assertEquals(expected.getTargetAmount(), actual.getTargetAmount());
        assertEquals(expected.getCurrentAmount(), actual.getCurrentAmount());
        assertEquals(expected.isObjectiveCompleted(), actual.isObjectiveCompleted());
        assertEquals(expected.getObjectiveName(), actual.getObjectiveName());
        if (expected instanceof DialogObjective expectedDialog) {
            DialogObjective actualDialog = assertInstanceOf(DialogObjective.class, actual);
            assertEquals(expectedDialog.getNpcFilename(), actualDialog.getNpcFilename());
            assertEquals(expectedDialog.getTargetLocation(), actualDialog.getTargetLocation());
            assertEquals(expectedDialog.getDialog(), actualDialog.getDialog());
        } else if (expected instanceof CustomFetchObjective expectedFetch) {
            CustomFetchObjective actualFetch = assertInstanceOf(CustomFetchObjective.class, actual);
            assertEquals(expectedFetch.getKey(), actualFetch.getKey());
            assertEquals(expectedFetch.isReadyToPickUp(), actualFetch.isReadyToPickUp());
            assertEquals(expectedFetch.isRequireItemTurnIn(), actualFetch.isRequireItemTurnIn());
        } else if (expected instanceof CustomKillObjective expectedKill) {
            assertEquals(expectedKill.getCustomBossFilename(), ((CustomKillObjective) actual).getCustomBossFilename());
        } else if (expected instanceof DynamicKillObjective expectedDynamic) {
            DynamicKillObjective actualDynamic = assertInstanceOf(DynamicKillObjective.class, actual);
            assertEquals(expectedDynamic.getEntityType(), actualDynamic.getEntityType());
            assertEquals(expectedDynamic.getMinMobLevel(), actualDynamic.getMinMobLevel());
        }
    }

    private static void assertRewardEquals(QuestReward expected, QuestReward actual) {
        assertEquals(expected.getRewardLevel(), actual.getRewardLevel());
        assertEquals(expected.getPlayerUUID(), actual.getPlayerUUID());
        assertEquals(expected.getCustomLootTable().getEntries().size(), actual.getCustomLootTable().getEntries().size());
        for (int index = 0; index < expected.getCustomLootTable().getEntries().size(); index++) {
            CustomLootEntry expectedEntry = expected.getCustomLootTable().getEntries().get(index);
            CustomLootEntry actualEntry = actual.getCustomLootTable().getEntries().get(index);
            assertEquals(expectedEntry.getClass(), actualEntry.getClass());
            assertEquals(expectedEntry.getChance(), actualEntry.getChance());
            assertEquals(expectedEntry.getAmount(), actualEntry.getAmount());
            assertEquals(expectedEntry.getPermission(), actualEntry.getPermission());
            assertEquals(expectedEntry.getWave(), actualEntry.getWave());
            assertEquals(expectedEntry.getItemLevel(), actualEntry.getItemLevel());
            if (expectedEntry instanceof CurrencyCustomLootEntry expectedCurrency)
                assertEquals(expectedCurrency.getCurrencyAmount(), ((CurrencyCustomLootEntry) actualEntry).getCurrencyAmount());
            if (expectedEntry instanceof VanillaCustomLootEntry expectedVanilla)
                assertEquals(expectedVanilla.getMaterial(), ((VanillaCustomLootEntry) actualEntry).getMaterial());
        }
    }

    private static void assertCooldownsEquals(PlayerQuestCooldowns expected, PlayerQuestCooldowns actual) {
        assertEquals(expected.getQuestCooldowns().size(), actual.getQuestCooldowns().size());
        for (int index = 0; index < expected.getQuestCooldowns().size(); index++) {
            QuestCooldown expectedCooldown = expected.getQuestCooldowns().get(index);
            QuestCooldown actualCooldown = actual.getQuestCooldowns().get(index);
            assertEquals(expectedCooldown.getPermission(), actualCooldown.getPermission());
            assertEquals(permanent(expectedCooldown), permanent(actualCooldown));
            assertEquals(expectedCooldown.getTargetUnixTime(), actualCooldown.getTargetUnixTime());
        }
    }

    private static boolean permanent(QuestCooldown cooldown) {
        try {
            Field field = QuestCooldown.class.getDeclaredField("permanent");
            field.setAccessible(true);
            return field.getBoolean(cooldown);
        } catch (ReflectiveOperationException exception) {
            throw new AssertionError(exception);
        }
    }
}
