package com.magmaguy.elitemobs.items;

import com.magmaguy.elitemobs.config.ItemSettingsConfig;
import com.magmaguy.elitemobs.skills.SkillType;
import org.junit.jupiter.api.Test;

import java.lang.reflect.Field;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNull;

class EliteItemLoreSkillRequirementTest {

    @Test
    void unrestrictedGearStillExplainsThatNoSkillIsRequired() throws Exception {
        Field field = ItemSettingsConfig.class.getDeclaredField("noSkillRequirementLore");
        field.setAccessible(true);
        Object previous = field.get(null);
        try {
            field.set(null, "NO SKILL REQUIRED");

            assertEquals("NO SKILL REQUIRED", EliteItemLore.skillRequirementLore(SkillType.ARMOR, null));
            assertNull(EliteItemLore.skillRequirementLore(null, null));
        } finally {
            field.set(null, previous);
        }
    }
}
