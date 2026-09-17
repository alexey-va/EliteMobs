package com.magmaguy.elitemobs.powers.lua;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.Objects;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;

class GrapplingHookScriptTest {

    @Test
    void acceptsBukkitProjectileTypeNames() throws IOException {
        String script;
        try (InputStream resource = getClass().getClassLoader()
                .getResourceAsStream("enchantments/grappling_hook.lua")) {
            script = new String(Objects.requireNonNull(resource).readAllBytes(), StandardCharsets.UTF_8);
        }

        assertTrue(script.contains("arrow.entity_type~='ARROW'"));
        assertTrue(script.contains("arrow.entity_type~='SPECTRAL_ARROW'"));
        assertFalse(script.contains("arrow.entity_type~='arrow'"));
        assertFalse(script.contains("arrow.entity_type~='spectral_arrow'"));
    }
}
