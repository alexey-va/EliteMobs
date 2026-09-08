"""Derive reviewed baseline profile defaults from the retained DLC evidence."""
from pathlib import Path
import json
import math
import yaml

ROOT = Path(__file__).resolve().parents[2]
report = json.loads((ROOT / "design/loot-analysis/corpus.json").read_text())
groups = {(g["difficulty"], g["rank"], g["family"]): g for g in report["statistics"]}
families = {
    "SWORDS": ("SHARPNESS", ["UNBREAKING", "FIRE_ASPECT", "KNOCKBACK", "LOOTING", "SWEEPING_EDGE", "MENDING", "CRITICAL_STRIKES"]),
    "AXES": ("SHARPNESS", ["UNBREAKING", "FIRE_ASPECT", "LOOTING", "MENDING", "CRITICAL_STRIKES"]),
    "BOWS": ("POWER", ["UNBREAKING", "FLAME", "PUNCH", "INFINITY", "MENDING", "CRITICAL_STRIKES"]),
    "CROSSBOWS": ("POWER", ["UNBREAKING", "QUICK_CHARGE", "MULTISHOT", "PIERCING", "MENDING", "CRITICAL_STRIKES"]),
    "TRIDENTS": ("SHARPNESS", ["UNBREAKING", "IMPALING", "LOYALTY", "CHANNELING", "MENDING", "CRITICAL_STRIKES"]),
    "HOES": ("SHARPNESS", ["UNBREAKING", "FIRE_ASPECT", "MENDING", "CRITICAL_STRIKES"]),
    "MACES": ("SHARPNESS", ["UNBREAKING", "FIRE_ASPECT", "MENDING", "CRITICAL_STRIKES"]),
    "SPEARS": ("SHARPNESS", ["UNBREAKING", "FIRE_ASPECT", "MENDING", "CRITICAL_STRIKES"]),
    "STAVES": ("POWER", ["UNBREAKING", "MENDING"]),
    "WANDS": ("POWER", ["UNBREAKING", "MENDING"]),
}
caps = {"FLAME": 1, "INFINITY": 1, "MENDING": 1, "CHANNELING": 1, "MULTISHOT": 1,
        "QUICK_CHARGE": 3, "PIERCING": 4, "LOYALTY": 3, "CRITICAL_STRIKES": 3}
defaults = {"enabled": True, "defaultDifficulty": "NORMAL",
            "difficultyIds": {"0": "NORMAL", "1": "HARD", "2": "MYTHIC"},
            "enchantmentBudgetFraction": 0.5, "minimumPrimaryLevel": 1,
            "dropChance": {"TRASH": .05, "MINIBOSS": .25, "BOSS": 1.0}, "profiles": {}}
provenance = []
previous_levels = {}
for diff in ("NORMAL", "HARD", "MYTHIC"):
    defaults["profiles"][diff] = {}
    for rank in ("TRASH", "MINIBOSS", "BOSS"):
        defaults["profiles"][diff][rank] = {}
        for family, (primary, secondary) in families.items():
            fallback = "BOWS" if primary == "POWER" else "SWORDS"
            profile = {"primaryEnchantment": primary, "enchantments": {}, "rareEnchantments": {}}
            for enchantment in [primary] + secondary:
                group = groups.get((diff, rank, family), {})
                stat = group.get("enchantments", {}).get(enchantment)
                source = family
                if family in ("STAVES", "WANDS") or stat is None or stat["count"] < 5:
                    substitute = groups.get((diff, rank, fallback), {}).get("enchantments", {}).get(enchantment)
                    if substitute is not None and (stat is None or substitute["count"] >= stat["count"]):
                        stat, source = substitute, fallback
                if stat is None:
                    if enchantment != primary:
                        continue
                    level = {"TRASH": 2, "MINIBOSS": 3, "BOSS": 5}[rank] + {"NORMAL": 0, "HARD": 1, "MYTHIC": 2}[diff]
                    chance, source = 1.0, "declared-no-sample-fallback"
                else:
                    level = math.floor(stat["medianPresent"] + .5)
                    chance = 1.0 if enchantment == primary else math.floor(stat["prevalence"] * 20 + .5) / 20
                level = min(level, caps.get(enchantment, 100))
                # A higher difficulty must not reduce the same rule's enchantment level.
                level = max(level, previous_levels.get((rank, family, enchantment), 0))
                previous_levels[(rank, family, enchantment)] = level
                if chance <= 0:
                    continue
                profile["enchantments"][enchantment] = {"level": level, "chance": chance}
                provenance.append({"difficulty": diff, "rank": rank, "family": family,
                                   "enchantment": enchantment, "sourceFamily": source,
                                   "positiveSamples": stat["count"] if stat else 0, "level": level, "chance": chance})
            # New mechanics have no DLC samples. These are deliberate, bounded v0 defaults.
            if family == "WANDS":
                level = 1 if diff == "NORMAL" else 2
                profile["enchantments"]["MULTICAST"] = {"level": level, "chance": {"TRASH": .10, "MINIBOSS": .25, "BOSS": .40}[rank]}
                if diff == "MYTHIC" and rank == "BOSS":
                    profile["rareEnchantments"]["MULTICAST"] = {"level": 3, "chance": .01}
            if family == "STAVES":
                level = {"NORMAL": 1, "HARD": 2, "MYTHIC": 3}[diff]
                for enchantment in ("BLAST_RADIUS", "IGNITION"):
                    profile["enchantments"][enchantment] = {"level": level, "chance": {"TRASH": .10, "MINIBOSS": .25, "BOSS": .40}[rank]}
            defaults["profiles"][diff][rank][family] = profile

destination = ROOT / "src/main/resources/classloot/defaults.yml"
destination.parent.mkdir(parents=True, exist_ok=True)
destination.write_text("# Authored ceilings derived from design/loot-analysis; native levels use the configured budget roll.\n"
                       + yaml.safe_dump(defaults, sort_keys=False, width=120), encoding="utf-8")
(ROOT / "design/loot-analysis/profile-provenance.json").write_text(json.dumps(provenance, indent=2) + "\n", encoding="utf-8")
print(f"Wrote 90 profiles and {len(provenance)} measured/fallback rules to {destination}")
