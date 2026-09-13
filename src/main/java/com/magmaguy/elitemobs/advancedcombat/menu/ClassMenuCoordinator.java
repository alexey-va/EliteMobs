package com.magmaguy.elitemobs.advancedcombat.menu;

import com.magmaguy.elitemobs.advancedcombat.AdvancedCombatModule;
import com.magmaguy.elitemobs.advancedcombat.presentation.ClassPresentationTheme;
import com.magmaguy.elitemobs.advancedcombat.progression.ProfileSnapshot;
import com.magmaguy.elitemobs.advancedcombat.progression.SelectionResult;
import com.magmaguy.elitemobs.playerdata.database.PlayerData;
import com.magmaguy.magmacore.util.ChatColorConverter;
import org.bukkit.entity.Player;

import java.util.Optional;

/** Owns action validation, authoritative refreshes, mutations and presentation routing. */
final class ClassMenuCoordinator {
    private final PlayerActionTokenRegistry tokens;
    private final ClassMenuRenderer dialogs;
    private final ClassMenuRenderer inventories;

    ClassMenuCoordinator(
            PlayerActionTokenRegistry tokens,
            ClassMenuRenderer dialogs,
            ClassMenuRenderer inventories) {
        this.tokens = tokens;
        this.dialogs = dialogs;
        this.inventories = inventories;
    }

    void open(Player player) {
        project(player).ifPresent(view -> {
            tokens.beginPage(player.getUniqueId());
            renderer(player).showOverview(player, view);
        });
    }

    void openForm(Player player, String formId) {
        openForm(player, formId, true);
    }

    void openForm(Player player, String formId, boolean showAllClasses) {
        project(player).ifPresent(view -> {
            ClassMenuView.FormView form = view.forms().get(formId);
            if (form == null) {
                send(player, "&cЭтой формы класса больше нет. Список классов обновлён.");
                open(player);
                return;
            }
            tokens.beginPage(player.getUniqueId());
            renderer(player).showForm(player, view, form, showAllClasses);
        });
    }

    void openControls(Player player) {
        project(player).ifPresent(view -> {
            tokens.beginPage(player.getUniqueId());
            renderer(player).showControls(player, view);
        });
    }

    void dispatch(Player player, String token) {
        Optional<ClassMenuAction> optionalAction = tokens.consume(player.getUniqueId(), token);
        if (optionalAction.isEmpty()) {
            send(player, "&eЭто действие устарело. Открыто обновлённое меню классов.");
            open(player);
            return;
        }
        ClassMenuAction action = optionalAction.get();
        switch (action) {
            case ClassMenuAction.OpenOverview ignored -> open(player);
            case ClassMenuAction.OpenControls ignored -> openControls(player);
            case ClassMenuAction.OpenForm openForm -> openForm(player, openForm.formId(), openForm.showAllClasses());
            case ClassMenuAction.SelectForm selectForm -> selectForm(player, selectForm.formId(), selectForm.showAllClasses());
            case ClassMenuAction.Challenge challenge ->
                    com.magmaguy.elitemobs.advancedcombat.challenges.ClassChallengeInstance.admit(
                            player, challenge.formId(), challenge.quotedFee());
            case ClassMenuAction.DeactivateClass ignored -> deactivateClass(player);
        }
    }

    private void deactivateClass(Player player) {
        if (!AdvancedCombatModule.isInitialized()) {
            open(player);
            return;
        }
        SelectionResult result = AdvancedCombatModule.get().clearSelectedForm(player);
        switch (result.status()) {
            case APPLIED -> send(player, "&aКласс отключён. Уровни сохранены; выбрать класс снова можно в меню классов.");
            case UNCHANGED -> send(player, "&7У вас нет активного класса.");
            case NOT_READY -> send(player, "&eДанные классов ещё загружаются.");
            case LOCKED_FORM -> send(player, "&cКласс нельзя сменить до завершения этого похода.");
            default -> send(player, "&cНе удалось отключить класс.");
        }
        open(player);
    }

    private Optional<ClassMenuView> project(Player player) {
        if (!AdvancedCombatModule.isInitialized()) {
            send(player, "&cНовая система классов отключена на этом сервере.");
            return Optional.empty();
        }
        AdvancedCombatModule module = AdvancedCombatModule.get();
        ProfileSnapshot profile = module.profile(player.getUniqueId()).orElse(null);
        if (profile == null) {
            send(player, "&eДанные классов ещё загружаются. Повторите через несколько секунд.");
            return Optional.empty();
        }
        // Both values are deliberately acquired here, for every render after every action.
        return Optional.of(ClassMenuProjector.project(
                module.catalog(),
                profile,
                skill -> PlayerData.getSkillLevel(player.getUniqueId(), skill)));
    }

    private void selectForm(Player player, String formId, boolean showAllClasses) {
        if (!AdvancedCombatModule.isInitialized()) {
            open(player);
            return;
        }
        SelectionResult result = AdvancedCombatModule.get().selectForm(player, formId);
        switch (result.status()) {
            case APPLIED -> {
                // Deliberately three tiny lines: players stop reading anything longer.
                send(player, ClassPresentationTheme.gradient(ClassPresentationTheme.GREEN,
                        "Класс выбран:") + " &f"
                        + AdvancedCombatModule.get().catalog().require(formId).displayName());
                send(player, ClassPresentationTheme.gradient(ClassPresentationTheme.GOLD,
                        "Управление:") + " &fF, F&7: мобильность | &fF + ЛКМ&7: коронный приём | &fF + ПКМ&7: особый навык.");
                send(player, ClassPresentationTheme.gradient(ClassPresentationTheme.RED,
                        "Оружие:") + " " + com.magmaguy.elitemobs.advancedcombat.ClassWeaponAffinity.description(
                        AdvancedCombatModule.get().catalog().require(formId)));
            }
            case UNCHANGED -> send(player, "&7Этот класс уже выбран.");
            case NOT_READY -> send(player, "&eДанные классов ещё загружаются.");
            case UNKNOWN_FORM -> send(player, "&cЭтой формы класса больше нет.");
            case LOCKED_FORM -> send(player, result.snapshot() != null
                    && result.snapshot().lockedRunSelection() != null
                    ? "&cКласс нельзя сменить до завершения этого похода."
                    : "&cЭта форма класса ещё не открыта.");
        }
        openForm(player, formId, showAllClasses);
    }

    private ClassMenuRenderer renderer(Player player) {
        return ClassSelectionMenu.supportsDialogs(player) ? dialogs : inventories;
    }

    private static void send(Player player, String message) {
        player.sendMessage(ChatColorConverter.convert(message));
    }
}
