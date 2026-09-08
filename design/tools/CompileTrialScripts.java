import com.magmaguy.elitemobs.powers.lua.EliteMobsScriptProvider;
import com.magmaguy.elitemobs.magmacore.scripting.ScriptDefinition;
import java.nio.file.*;
import java.nio.charset.StandardCharsets;

/** Syntax and canonical hook validation only; does not start Bukkit or execute encounter hooks. */
class CompileTrialScripts {
    public static void main(String[] args) throws Exception {
        Path root = Path.of(args[0]);
        String shared = Files.readString(root.resolve("shared.lua"), StandardCharsets.UTF_8);
        int count = 0;
        for (int i = 1; i < args.length; i++) {
            String[] pair = args[i].split(":", 2);
            Path source = root.resolve("encounters/" + pair[1] + ".lua");
            String code = shared + "\n" + Files.readString(root.resolve("mobility/" + pair[0] + ".lua"))
                    + "\n" + (Files.exists(root.resolve("powers/" + pair[0] + ".lua"))
                        ? Files.readString(root.resolve("powers/" + pair[0] + ".lua")) : "")
                    + "\n" + Files.readString(source);
            ScriptDefinition.validate(pair[1], source.toFile(), code, new EliteMobsScriptProvider(root));
            count++;
        }
        System.out.println("Compiled and validated canonical hook declarations for " + count + " encounter scripts; no gameplay executed.");
    }
}

