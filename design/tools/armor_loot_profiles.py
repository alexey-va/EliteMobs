"""Equipment-role extension used by the canonical class-loot defaults builder."""
import json
import math
import re
import statistics

SLOTS = ("HELMETS", "CHESTPLATES", "LEGGINGS", "BOOTS")

def role(row):
    match = re.search(r"_(dps|tank)(?:_|\.)", row["item"].lower())
    # Filenames are evidence labels, not a runtime classifier.
    if match:
        return match.group(1).upper()
    return None

def extend(defaults, root):
    evidence = json.loads((root / "design/loot-analysis/armor-observations.json").read_text(encoding="utf8"))
    rows = evidence["observations"]
    rows = list({(r["item"], r["rank"], r["difficulty"]): r for r in rows
                 if r["difficulty"] in ("NORMAL", "HARD", "MYTHIC")}.values())
    provenance = []
    previous = {}
    for difficulty in ("NORMAL", "HARD", "MYTHIC"):
        for rank in ("TRASH", "MINIBOSS", "BOSS"):
            for family in [f"{r}_{s}" for r in ("DPS", "TANK") for s in SLOTS] + ["SHIELDS"]:
                desired_role, slot = family.split("_", 1) if "_" in family else ("TANK", "SHIELDS")
                peers = [r for r in rows if r["difficulty"] == difficulty and r["rank"] == rank]
                exact = [r for r in peers if r["family"] == slot and role(r) == desired_role]
                same_role = [r for r in peers if r["family"] in SLOTS and role(r) == desired_role]
                same_slot = [r for r in peers if r["family"] == slot]
                primary = "SHARPNESS" if desired_role == "DPS" else "PROTECTION"
                secondary = (["PROTECTION", "UNBREAKING", "SMITE", "BANE_OF_ARTHROPODS"]
                             if desired_role == "DPS" else
                             ["UNBREAKING", "FIRE_PROTECTION", "BLAST_PROTECTION", "PROJECTILE_PROTECTION", "THORNS"])
                if slot == "SHIELDS": secondary = ["UNBREAKING", "MENDING"]
                if slot == "HELMETS": secondary += ["RESPIRATION", "AQUA_AFFINITY"]
                if slot == "BOOTS": secondary += ["FEATHER_FALLING", "DEPTH_STRIDER"]
                profile = dict(primaryEnchantment=primary, enchantments={}, rareEnchantments={}, potionEffects=[])
                for enchantment in [primary] + secondary:
                    selected, source, positives = [], "declared-no-sample-fallback", []
                    sources = ((same_slot, "same-slot-all-roles"),) if slot == "SHIELDS" else (
                        (exact, "same-role-and-slot"), (same_role, "same-role-other-slots"),
                        (same_slot, "same-slot-all-roles"))
                    for sample, label in sources:
                        values = [r["enchantments"].get(enchantment, 0) for r in sample
                                  if r["enchantments"].get(enchantment, 0) > 0]
                        if len(values) >= 5:
                            selected, source, positives = sample, label, values
                            break
                    if not positives:
                        if enchantment not in (primary, "UNBREAKING", "PROTECTION"): continue
                        level = ({"TRASH": 2, "MINIBOSS": 3, "BOSS": 5}[rank]
                                 + {"NORMAL": 0, "HARD": 1, "MYTHIC": 2}[difficulty])
                        if enchantment != primary: level = max(1, level // 2)
                        chance = 1.0 if enchantment == primary or enchantment == "PROTECTION" else .5
                    else:
                        level = math.floor(statistics.median(positives) + .5)
                        chance = 1.0 if enchantment == primary else math.floor(len(positives) / len(selected) * 20 + .5) / 20
                    level = min(level, {"MENDING": 1, "AQUA_AFFINITY": 1, "DEPTH_STRIDER": 3}.get(enchantment, 100))
                    key = (rank, family, enchantment)
                    level = max(level, previous.get(key, 0))
                    previous[key] = level
                    if chance <= 0: continue
                    profile["enchantments"][enchantment] = dict(level=level, chance=chance)
                    provenance.append(dict(difficulty=difficulty, rank=rank, family=family, enchantment=enchantment,
                                           source=source, positiveSamples=len(positives), sampleItems=len(selected),
                                           level=level, chance=chance))
                # Do not turn a rare authored proc into a permanent benefit on every generated piece.
                effect = "STRENGTH" if desired_role == "DPS" else "RESISTANCE"
                amplitudes = []
                for row in exact:
                    for raw in row.get("potionEffects", []):
                        parts = [x.strip().upper() for x in str(raw).split(",")]
                        if len(parts) != 4: continue
                        parts[0] = {"INCREASE_DAMAGE": "STRENGTH", "DAMAGE_RESISTANCE": "RESISTANCE"}.get(parts[0], parts[0])
                        if parts[0] == effect and parts[2:] == ["SELF", "ONHIT"]:
                            amplitudes.append(int(parts[1]))
                            break
                if len(amplitudes) >= 5 and len(amplitudes) >= len(exact) / 2:
                    amplifier = math.floor(statistics.median(amplitudes) + .5)
                    key = (rank, family, effect)
                    amplifier = max(amplifier, previous.get(key, 0))
                    previous[key] = amplifier
                    profile["potionEffects"] = [f"{effect},{amplifier},SELF,ONHIT"]
                elif (rank, family, effect) in previous:
                    profile["potionEffects"] = [f"{effect},{previous[(rank, family, effect)]},SELF,ONHIT"]
                defaults["profiles"][difficulty][rank][family] = profile
                provenance.append(dict(difficulty=difficulty, rank=rank, family=family, effect=effect,
                                       source="same-role-and-slot-majority-onhit", positiveSamples=len(amplitudes),
                                       sampleItems=len(exact), potionEffects=profile["potionEffects"]))
    (root / "design/loot-analysis/armor-profile-provenance.json").write_text(
        json.dumps(dict(generation=evidence["generation"], rules=provenance), indent=2) + "\n", encoding="utf8")
