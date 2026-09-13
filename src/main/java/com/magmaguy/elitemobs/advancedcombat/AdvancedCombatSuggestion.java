package com.magmaguy.elitemobs.advancedcombat;

import com.magmaguy.elitemobs.MetadataHandler;
import com.magmaguy.elitemobs.config.AdvancedCombatSystemConfig;
import com.magmaguy.magmacore.util.SpigotMessage;
import org.bukkit.entity.Player;
import org.bukkit.event.EventHandler;
import org.bukkit.event.EventPriority;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerJoinEvent;
import org.bukkit.scheduler.BukkitRunnable;

/** Shows the developer's combat announcement until an administrator disables it for the server. */
public final class AdvancedCombatSuggestion implements Listener {
    private static final long REMINDER_DELAY_TICKS = 100L;
    private static final String DEVELOPER_MESSAGE_URL = "https://www.patreon.com/posts/169211257";

    @EventHandler(priority = EventPriority.MONITOR)
    public void onPlayerJoin(PlayerJoinEvent event) {
        Player player = event.getPlayer();
        if (!shouldSuggest(player)) return;
        new BukkitRunnable() {
            @Override
            public void run() {
                if (!player.isOnline() || !shouldSuggest(player)) return;
                sendSuggestion(player);
            }
        }.runTaskLater(MetadataHandler.PLUGIN, REMINDER_DELAY_TICKS);
    }

    private boolean shouldSuggest(Player player) {
        return AdvancedCombatSystemConfig.isShowDeveloperMessage()
                && player.hasPermission("elitemobs.advancedcombat.admin");
    }

    private static void sendSuggestion(Player player) {
        player.spigot().sendMessage(
                SpigotMessage.simpleMessage("&6[EliteMobs] &fСообщение разработчика MagmaGuy о новой боевой системе. "),
                SpigotMessage.hoverLinkMessage(
                        "&a[Прочитать]",
                        "&7Открыть бесплатную публикацию MagmaGuy на Patreon",
                        DEVELOPER_MESSAGE_URL),
                SpigotMessage.simpleMessage(" "),
                SpigotMessage.commandHoverMessage(
                        "&c[Больше не показывать]",
                        "&7Скрыть это сообщение для всех администраторов сервера",
                        "/em advancedcombat dismiss"));
    }
}
