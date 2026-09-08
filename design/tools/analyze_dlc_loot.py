"""Read an immutable DLC generation and report authored loot statistics. Never writes to DLC."""
from __future__ import annotations

import argparse
import collections
import csv
import hashlib
import json
import re
import statistics
from pathlib import Path

import yaml

ALIASES = {
    "DAMAGE_ALL": "SHARPNESS", "DAMAGE_UNDEAD": "SMITE", "DAMAGE_ARTHROPODS": "BANE_OF_ARTHROPODS",
    "ARROW_DAMAGE": "POWER", "ARROW_FIRE": "FLAME", "ARROW_INFINITE": "INFINITY",
    "ARROW_KNOCKBACK": "PUNCH", "DURABILITY": "UNBREAKING", "LOOT_BONUS_MOBS": "LOOTING",
    "LOOT_BONUS_BLOCKS": "FORTUNE", "DIG_SPEED": "EFFICIENCY", "PROTECTION_ENVIRONMENTAL": "PROTECTION",
    "PROTECTION_FIRE": "FIRE_PROTECTION", "PROTECTION_FALL": "FEATHER_FALLING",
    "PROTECTION_EXPLOSIONS": "BLAST_PROTECTION", "PROTECTION_PROJECTILE": "PROJECTILE_PROTECTION",
    "OXYGEN": "RESPIRATION", "WATER_WORKER": "AQUA_AFFINITY", "SWEEPING": "SWEEPING_EDGE",
    "LUCK": "LUCK_OF_THE_SEA", "SOULBIND": "SOULBIND",
}
DIFFICULTIES = {"0": "NORMAL", "1": "HARD", "2": "MYTHIC"}


def family(item):
    explicit = str(item.get("weaponType", "")).upper()
    if explicit in ("STAVES", "WANDS"):
        return explicit
    material = str(item.get("material", "")).upper()
    for suffix, kind in [("_SWORD", "SWORDS"), ("_AXE", "AXES"), ("_HOE", "HOES"),
                         ("_SPEAR", "SPEARS"), ("_HELMET", "HELMETS"), ("_CHESTPLATE", "CHESTPLATES"),
                         ("_LEGGINGS", "LEGGINGS"), ("_BOOTS", "BOOTS")]:
        if material.endswith(suffix):
            return kind
    return {"BOW": "BOWS", "CROSSBOW": "CROSSBOWS", "TRIDENT": "TRIDENTS", "MACE": "MACES",
            "SHIELD": "SHIELDS", "ELYTRA": "CHESTPLATES"}.get(material, "NONCOMBAT")


def rank(boss, path):
    explicit = str(boss.get("bossType", "")).upper()
    if explicit:
        return {"NORMAL": "TRASH", "EVENT": "BOSS"}.get(explicit, explicit), "bossType"
    name = str(boss.get("name", ""))
    if "$minibossLevel" in name or re.search(r"(?:^|_)miniboss(?:_|\.)", path.name, re.I):
        return "MINIBOSS", "inferred-name"
    if "$bossLevel" in name or re.search(r"(?:^|_)(?:final_)?boss(?:_|\.)", path.name, re.I):
        return "BOSS", "inferred-name"
    return "TRASH", "runtime-default"


def difficulty(item_path, entry):
    if "difficultyID" in entry:
        value = str(entry["difficultyID"])
        return DIFFICULTIES.get(value, "UNKNOWN:" + value), "loot-difficultyID"
    matches = set(re.findall(r"(?:^|[/_\[ ])(normal|hard|mythic)(?=[/_.\] ]|$)", item_path.lower()))
    if len(matches) == 1:
        return matches.pop().upper(), "item-path"
    return "NEUTRAL", "no-difficulty"


def loot_entry(raw):
    if isinstance(raw, dict):
        return raw
    if isinstance(raw, str):
        if "=" not in raw:
            parts = raw.split(":")
            if len(parts) >= 2 and parts[0].lower().endswith((".yml", ".yaml")):
                return {"filename": parts[0], "chance": parts[1]}
        return dict(part.split("=", 1) for part in raw.split(":") if "=" in part)
    return {}


def enchantments(item, path, issues):
    result = {}
    for raw in item.get("enchantments", []) or []:
        try:
            key, value = str(raw).split(",", 1)
            key = ALIASES.get(key.strip().upper(), key.strip().upper())
            result[key] = max(result.get(key, 0), int(value.strip()))
        except (ValueError, TypeError):
            issues.append({"path": path, "reason": "invalid-enchantment", "entry": raw})
    return result


def summarize(rows):
    groups = collections.defaultdict(dict)
    for row in rows:
        groups[(row["difficulty"], row["rank"], row["family"])][row["item"]] = row
    result = []
    for (diff, mob_rank, kind), by_item in sorted(groups.items()):
        items = list(by_item.values())
        keys = sorted({key for item in items for key in item["enchantments"]})
        levels = [v["itemLevel"] for v in items if isinstance(v["itemLevel"], (float, int))]
        stats = {}
        for key in keys:
            values = [item["enchantments"].get(key, 0) for item in items]
            positive = [v for v in values if v > 0]
            if not positive:
                continue
            stats[key] = {"count": len(positive), "prevalence": round(len(positive) / len(items), 4),
                          "medianPresent": statistics.median(positive), "medianAll": statistics.median(values),
                          "min": min(positive), "max": max(positive)}
        result.append({"difficulty": diff, "rank": mob_rank, "family": kind, "items": len(items),
                       "packages": len({i["package"] for i in items}),
                       "medianItemLevel": statistics.median(levels) if levels else None,
                       "medianEnchantmentBudget": statistics.median(sum(i["enchantments"].values()) for i in items),
                       "enchantments": stats})
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("generation", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    root, output = args.generation.resolve(), args.output.resolve()
    if output == root or root in output.parents:
        raise SystemExit("Analysis output must be outside the immutable DLC generation")
    issues, items, bosses = [], {}, {}
    by_name = collections.defaultdict(list)
    inventory = {p.name: collections.Counter() for p in root.iterdir() if p.is_dir()}
    loader = getattr(yaml, "CSafeLoader", yaml.SafeLoader)
    for path in sorted(root.rglob("*")):
        if path.suffix.lower() not in (".yml", ".yaml"):
            continue
        parts = path.relative_to(root).parts
        kind = next((k for k in ("customitems", "custombosses", "customtreasurechests", "content_packages") if k in parts), None)
        if kind is None:
            continue
        rel = path.relative_to(root).as_posix()
        try:
            data = yaml.load(path.read_text(encoding="utf-8-sig"), Loader=loader)
        except (yaml.YAMLError, UnicodeError) as error:
            issues.append({"path": rel, "reason": "parse-error", "detail": str(error)[:300]})
            continue
        if not isinstance(data, dict):
            continue
        inventory[parts[0]][kind] += 1
        if kind == "customitems":
            items[rel] = {"package": parts[0], "item": rel, "family": family(data),
                          "material": data.get("material"), "itemLevel": data.get("level"),
                          "scalability": data.get("scalability", "fixed"),
                          "enchantments": enchantments(data, rel, issues), "enabled": data.get("isEnabled", True)}
            by_name[path.name.lower()].append(rel)
        elif kind == "custombosses":
            bosses[rel] = data
    rows, excluded, unresolved, referenced = [], collections.Counter(), [], set()
    for rel, boss in bosses.items():
        package = rel.split("/", 1)[0]
        mob_rank, rank_source = rank(boss, Path(rel))
        reason = None
        if boss.get("isEnabled") is False:
            reason = "disabled-boss"
        elif boss.get("isReinforcement") or mob_rank == "REINFORCEMENT" or "reinforcement" in Path(rel).name.lower():
            reason = "reinforcement"
        for raw in boss.get("uniqueLootList", []) or []:
            entry = loot_entry(raw)
            if reason:
                excluded[reason] += 1
                continue
            if "filename" not in entry:
                excluded["non-item-loot-entry"] += 1
                continue
            try:
                if float(entry.get("chance", 1)) <= 0:
                    excluded["zero-chance"] += 1
                    continue
            except (TypeError, ValueError):
                issues.append({"path": rel, "reason": "invalid-chance", "entry": entry})
                continue
            name = str(entry["filename"]).replace("\\", "/").split("/")[-1].lower()
            candidates = by_name.get(name, [])
            local = [v for v in candidates if v.split("/", 1)[0] == package]
            resolved = local or candidates
            if len(resolved) != 1:
                unresolved.append({"boss": rel, "filename": entry["filename"], "matches": resolved})
                continue
            item = items[resolved[0]]
            referenced.add(item["item"])
            if item["enabled"] is False or item["family"] == "NONCOMBAT":
                excluded["disabled-item" if item["enabled"] is False else "noncombat-item"] += 1
                continue
            diff, diff_source = difficulty(item["item"], entry)
            rows.append({**item, "boss": rel, "rank": mob_rank, "rankSource": rank_source,
                         "ordinaryLootEnabled": boss.get("dropsEliteMobsLoot", True),
                         "difficulty": diff, "difficultySource": diff_source, "chance": entry.get("chance", 1)})
    # Unreferenced combat items remain visible, but are not evidence for a mob rank.
    unreferenced = []
    for item in items.values():
        if item["item"] not in referenced and item["family"] != "NONCOMBAT" and item["enabled"]:
            diff, source = difficulty(item["item"], {})
            unreferenced.append({**item, "rank": "UNREFERENCED", "difficulty": diff, "difficultySource": source})
    stats = summarize(rows)
    paired = collections.defaultdict(dict)
    for row in rows:
        if row["difficulty"] in DIFFICULTIES.values():
            base = re.sub(r"(?i)(normal|hard|mythic)", "DIFFICULTY", row["item"])
            paired[(base, row["rank"], row["family"])][row["difficulty"]] = row
    paired_deltas = collections.defaultdict(list)
    for (_, mob_rank, kind), variants in paired.items():
        if "NORMAL" not in variants:
            continue
        base = variants["NORMAL"]["enchantments"]
        for diff in ("HARD", "MYTHIC"):
            if diff not in variants:
                continue
            for key in base.keys() | variants[diff]["enchantments"].keys():
                paired_deltas[(diff, mob_rank, kind, key)].append(variants[diff]["enchantments"].get(key, 0) - base.get(key, 0))
    manifest = root / ".source-manifest.json"
    report = {"generation": root.name, "manifestFileSha256": hashlib.sha256(manifest.read_bytes()).hexdigest(),
              "inventory": inventory, "itemFiles": len(items), "bossFiles": len(bosses), "lootReferences": len(rows),
              "uniqueReferencedCombatItems": len({r["item"] for r in rows}),
              "rankSources": dict(collections.Counter(r["rankSource"] for r in rows)),
              "difficultySources": dict(collections.Counter(r["difficultySource"] for r in rows)),
              "excluded": excluded, "issues": issues, "unresolved": unresolved,
              "statistics": stats, "unreferencedStatistics": summarize(unreferenced),
              "pairedDifficultyDeltas": [{"difficulty": d, "rank": r, "family": f, "enchantment": e,
                                            "pairs": len(v), "medianDelta": statistics.median(v)}
                                           for (d, r, f, e), v in sorted(paired_deltas.items())]}
    output.mkdir(parents=True, exist_ok=True)
    (output / "corpus.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    (output / "observations.json").write_text(json.dumps(rows, indent=2) + "\n", encoding="utf-8")
    (output / "unreferenced-items.json").write_text(json.dumps(unreferenced, indent=2) + "\n", encoding="utf-8")
    with (output / "medians.csv").open("w", newline="", encoding="utf-8") as file:
        writer = csv.writer(file)
        writer.writerow(["difficulty", "rank", "family", "items", "packages", "enchantment", "present", "prevalence", "medianPresent", "medianAll", "min", "max"])
        for group in stats:
            for key, values in group["enchantments"].items():
                writer.writerow([group[k] for k in ("difficulty", "rank", "family", "items", "packages")]
                                + [key] + [values[k] for k in ("count", "prevalence", "medianPresent", "medianAll", "min", "max")])
    print(json.dumps({k: report[k] for k in ("generation", "itemFiles", "bossFiles", "lootReferences", "uniqueReferencedCombatItems", "rankSources", "difficultySources", "excluded")}, indent=2))
    print(f"Unresolved references: {len(unresolved)}; parse/value issues: {len(issues)}; groups: {len(stats)}")


if __name__ == "__main__":
    main()
