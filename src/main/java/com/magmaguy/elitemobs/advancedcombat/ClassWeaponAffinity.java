package com.magmaguy.elitemobs.advancedcombat;

import com.magmaguy.elitemobs.api.EliteMobDamagedByPlayerEvent;
import com.magmaguy.elitemobs.advancedcombat.classes.ClassFormDefinition;
import com.magmaguy.elitemobs.advancedcombat.presentation.ClassPresentationTheme;
import com.magmaguy.elitemobs.presentation.actionbar.ActionBarCompositor;
import com.magmaguy.elitemobs.skills.SkillType;
import com.magmaguy.elitemobs.skills.WeaponIdentityResolver;
import com.magmaguy.magmacore.util.ChatColorConverter;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.EventPriority;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerQuitEvent;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;
import java.util.UUID;
import java.util.stream.Collectors;

/**
 * Encourages playing the active class's weapons: class weapons hit elites 10% harder and
 * off-class weapons 20% softer, with a rate-limited action-bar reminder. Vanilla-mob combat is
 * deliberately untouched because EliteMobs separates elite combat from vanilla balance.
 */
public final class ClassWeaponAffinity implements Listener {

    private static final int CLASS_WEAPON_BONUS_PERCENT = 10;
    private static final double CLASS_WEAPON_MULTIPLIER = 1D + CLASS_WEAPON_BONUS_PERCENT / 100D;
    private static final int OFF_CLASS_WEAPON_PENALTY_PERCENT = 20;
    private static final double OFF_CLASS_WEAPON_MULTIPLIER = 1D - OFF_CLASS_WEAPON_PENALTY_PERCENT / 100D;
    private static final long WARNING_INTERVAL_MILLIS = 5L * 60L * 1_000L;

    private final Map<UUID, Long> lastWarnings = new HashMap<>();
    private final Set<UUID> chatWarnedThisSession = new HashSet<>();

    @EventHandler(priority = EventPriority.HIGH, ignoreCancelled = true)
    public void onEliteDamagedByPlayer(EliteMobDamagedByPlayerEvent event) {
        if (com.magmaguy.elitemobs.combatsystem.CombatDamageContext.isDamageTransferActive()) return;
        Player player = event.getPlayer();
        if (!AdvancedCombatModule.isInitialized()) return;
        AdvancedCombatModule module = AdvancedCombatModule.get();
        if (!module.mechanicsActive(player) || !module.hasActiveClass(player)) return;
        SkillType weaponSkill = WeaponIdentityResolver.progressionSkill(
                player.getInventory().getItemInMainHand());
        if (weaponSkill == null) return; // bare hands and non-weapons stay neutral
        boolean classWeapon = module.activeClassWeaponAffinities(player).contains(weaponSkill);
        event.setDamage(event.getDamage()
                * (classWeapon ? CLASS_WEAPON_MULTIPLIER : OFF_CLASS_WEAPON_MULTIPLIER));
        if (!classWeapon) warnOffClassWeapon(player, module);
    }

    private void warnOffClassWeapon(Player player, AdvancedCombatModule module) {
        long now = System.currentTimeMillis();
        Long previous = lastWarnings.get(player.getUniqueId());
        if (previous != null && now - previous < WARNING_INTERVAL_MILLIS) return;
        ClassFormDefinition form = module.profile(player.getUniqueId())
                .flatMap(profile -> profile.optionalActiveLineage())
                .map(active -> module.catalog().require(active.activeFormId()))
                .orElse(null);
        if (form == null) return;
        lastWarnings.put(player.getUniqueId(), now);
        String header = ClassPresentationTheme.gradient(ClassPresentationTheme.RED, "Чужое оружие");
        String bonus = bonusDescription(form);
        ActionBarCompositor.show(
                player,
                ActionBarCompositor.Source.AFFINITY_WARNING,
                ChatColorConverter.convert(
                        header + " &8» &c-" + OFF_CLASS_WEAPON_PENALTY_PERCENT + "% урона&7. " + bonus));
        if (chatWarnedThisSession.add(player.getUniqueId()))
            player.sendMessage(ChatColorConverter.convert(
                    header + " &8» &7Это оружие не подходит вашему классу: &c-"
                            + OFF_CLASS_WEAPON_PENALTY_PERCENT + "% урона&7."
                            + " " + bonus));
    }

    public static String description(ClassFormDefinition form) {
        return bonusDescription(form) + " &7Остальное оружие наносит на &c"
                + OFF_CLASS_WEAPON_PENALTY_PERCENT + "% меньше урона&7.";
    }

    private static String bonusDescription(ClassFormDefinition form) {
        return "&f" + form.weaponAffinities().stream()
                .map(com.magmaguy.elitemobs.config.menus.premade.SkillBonusMenuConfig::getSkillTypeDisplayName)
                .collect(Collectors.joining(" &7и &f"))
                + " &7наносят на &a" + CLASS_WEAPON_BONUS_PERCENT + "% больше урона &7для класса &f"
                + form.displayName() + "&7.";
    }

    @EventHandler(priority = EventPriority.MONITOR)
    public void onQuit(PlayerQuitEvent event) {
        lastWarnings.remove(event.getPlayer().getUniqueId());
        chatWarnedThisSession.remove(event.getPlayer().getUniqueId());
    }

    void shutdown() {
        lastWarnings.clear();
        chatWarnedThisSession.clear();
    }
}
