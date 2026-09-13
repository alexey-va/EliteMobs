package com.magmaguy.elitemobs.advancedcombat.presentation;

import com.magmaguy.elitemobs.advancedcombat.classes.AbilitySlot;
import com.magmaguy.elitemobs.advancedcombat.progression.ClassProgressionModule;
import com.magmaguy.elitemobs.advancedcombat.progression.SkillTutorialProgress;
import com.magmaguy.magmacore.util.ChatColorConverter;
import org.bukkit.entity.Player;

import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

/** Chat onboarding; only the prompt throttle is session-scoped, milestones live in the class store. */
public final class ClassSkillTutorial {
    public static final String CONTROLS = "&7F, F: мобильность | F + ЛКМ: коронный приём | F + ПКМ: особый навык";
    private final Set<UUID> prompted = new HashSet<>();

    public void prompt(Player player, ClassProgressionModule progression, boolean waiting) {
        if (prompted.contains(player.getUniqueId())) return;
        progression.tutorialProgress(player.getUniqueId()).ifPresent(progress -> {
            if (progress.complete()) return;
            prompted.add(player.getUniqueId());
            message(player, "&eИспытайте все три навыка класса! &7Нажмите и отпустите клавишу смены рук"
                    + " (обычно F), затем быстро выполните второе действие.");
            if (waiting) message(player, "&aВо время ожидания ресурс класса не расходуется. Попробуйте навыки здесь!");
            showRemaining(player, progress);
        });
    }

    public void successfulCast(Player player, ClassProgressionModule progression, AbilitySlot slot) {
        progression.recordTutorialSkill(player.getUniqueId(), slot).ifPresent(progress -> {
            if (progress.complete()) {
                message(player, "&aВы применили все три навыка класса! Обучение завершено, подсказки больше не появятся.");
            } else {
                message(player, "&aНавык «" + name(slot) + "» освоен! &7Осталось попробовать:");
                showRemaining(player, progress);
            }
        });
    }

    private static void showRemaining(Player player, SkillTutorialProgress progress) {
        if (!progress.hasUsed(AbilitySlot.MOBILITY)) message(player, "&fF, затем F &8— &bМобильность");
        if (!progress.hasUsed(AbilitySlot.SIGNATURE)) message(player, "&fF, затем ЛКМ &8— &bКоронный приём");
        if (!progress.hasUsed(AbilitySlot.UTILITY)) message(player, "&fF, затем ПКМ &8— &bОсобый навык");
        message(player, "&7Навык засчитывается после успешного применения. Для направленных навыков нужна подходящая цель.");
    }

    private static String name(AbilitySlot slot) {
        return switch (slot) {
            case MOBILITY -> "Мобильность";
            case SIGNATURE -> "Коронный приём";
            case UTILITY -> "Особый навык";
        };
    }

    private static void message(Player player, String text) {
        player.sendMessage(ChatColorConverter.convert("&6[Навыки класса] &r" + text));
    }

    public void discard(UUID playerId) { prompted.remove(playerId); }
    public void clear() { prompted.clear(); }
}
