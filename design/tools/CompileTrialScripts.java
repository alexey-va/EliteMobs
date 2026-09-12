import com.magmaguy.elitemobs.powers.lua.LuaPowerManager;
import com.magmaguy.elitemobs.config.powers.PowersConfigFields.PowerType;
import java.nio.file.*;

/** Syntax and canonical hook validation only; does not start Bukkit or execute encounter hooks. */
class CompileTrialScripts {
    public static void main(String[] args) throws Exception {
        Path root = Path.of(args[0]);
        int count = 0;
        try (var sources = Files.list(root)) {
            for (Path source : sources.filter(path -> path.toString().endsWith(".lua")).sorted().toList()) {
                LuaPowerManager.loadLuaPower(source.getFileName().toString(), source.toFile(), null, PowerType.UNIQUE);
                count++;
            }
        }
        System.out.println("Compiled and validated canonical hook declarations for " + count + " encounter scripts; no gameplay executed.");
    }
}
