# DLC loot evidence

Snapshot: `20260907T031342379Z-d4164626b272-61c37e91`. The immutable generation contains 58 packages. All relevant YAML was read; no DLC was changed.

## Coverage

- 2,566 item definitions and 1,675 mob definitions parsed, with no YAML or enchantment-value parse failures.
- 4,417 eligible authored combat-loot references resolve to 2,012 distinct item files.
- 555 normal, 484 hard, 469 mythic and 507 difficulty-neutral item files are referenced. Some items occur in more than one group.
- 68 references to 44 filenames do not resolve in this snapshot. `corpus.json` records every reference and candidate; many are built-in books/scrap, while others appear to be missing or misspelled DLC filenames.
- All item families, including armor and shields, are reported in `medians.csv`. Magic items have no explicit STAVES/WANDS samples. A blaze rod or stick alone is not evidence of a working magic weapon.

## Method

Normalize legacy enchantment aliases, then follow actual `uniqueLootList` entries in both map and legacy string formats. Explicit `difficultyID` uses the plugin mapping 0/1/2 = normal/hard/mythic. Otherwise use an unambiguous item path; leave everything else neutral. Comments in content package YAML are not active difficulty definitions; the plugin supplies the canonical defaults.

Use explicit `bossType` first. With it absent, recognize boss/miniboss name tokens and filename markers, otherwise retain the runtime NORMAL default as trash. `rankSource` records that distinction. Of the 4,417 references, 2,278 use explicit rank, 596 use name inference and 1,543 use the runtime default. The inferred/default classification deserves particular attention in the manual pass.

Each item contributes once per difficulty/rank/family group even when copied mobs or encounter phases reference it repeatedly. Preserve reference-level data separately in `observations.json`. Report median among positive levels and median including absent enchantments, prevalence, min/max and package/sample counts. A missing group is missing evidence, not a zero-level enchantment. Unreferenced combat items remain in `unreferenced-items.json` and separate statistics, rather than being assigned an invented mob rank.

Exclude disabled bosses/items, reinforcements, zero-chance entries and noncombat rewards. `dropsEliteMobsLoot: false` does not exclude authored drops: `CustomBossDeath` awards these independently from the ordinary loot switch. This distinction is necessary for the majority of difficulty-tagged dungeon loot.

## Primary enchantment medians

Numbers below are positive-level medians. Parentheses show the number of items carrying that enchantment, not the total group size. A dash means no positive sample. Sharpness is shown for melee families, Power for bows/crossbows, and Impaling for tridents. Some legacy crossbow and spear enchants have no matching native effect; observations are not automatically a compatibility recommendation.

| Family | Rank | Normal | Hard | Mythic |
|---|---|---:|---:|---:|
| SWORDS | TRASH | 2 (14) | 3 (15) | 4 (13) |
| SWORDS | MINIBOSS | 3 (13) | 3 (9) | 4 (9) |
| SWORDS | BOSS | 5 (19) | 6.5 (20) | 8.5 (18) |
| AXES | TRASH | 3 (4) | 4 (4) | 5 (4) |
| AXES | MINIBOSS | 3 (8) | 3.5 (6) | 4 (5) |
| AXES | BOSS | 3 (8) | 4.5 (8) | 6 (8) |
| BOWS | TRASH | 1.5 (6) | 2.5 (6) | 4 (5) |
| BOWS | MINIBOSS | 3 (9) | 3 (7) | 4 (7) |
| BOWS | BOSS | 4 (21) | 5 (21) | 7 (21) |
| CROSSBOWS | TRASH | - | - | - |
| CROSSBOWS | MINIBOSS | 1 (2) | 3 (2) | 3 (2) |
| CROSSBOWS | BOSS | - | - | - |
| TRIDENTS | TRASH | - | - | - |
| TRIDENTS | MINIBOSS | 3.5 (4) | 5 (3) | 6 (3) |
| TRIDENTS | BOSS | 4 (2) | 5.5 (2) | 6.5 (2) |
| HOES | TRASH | - | - | - |
| HOES | MINIBOSS | 5 (1) | 7 (1) | 9 (1) |
| HOES | BOSS | 5 (9) | 6 (9) | 8 (9) |
| MACES | TRASH | - | - | - |
| MACES | MINIBOSS | 5 (1) | 7 (1) | 9 (1) |
| MACES | BOSS | 5 (21) | 6 (21) | 8 (21) |
| SPEARS | TRASH | - | - | - |
| SPEARS | MINIBOSS | 4 (1) | 6 (1) | 8 (1) |
| SPEARS | BOSS | 4 (19) | 6 (19) | 8 (19) |
| STAVES | TRASH | - | - | - |
| STAVES | MINIBOSS | - | - | - |
| STAVES | BOSS | - | - | - |
| WANDS | TRASH | - | - | - |
| WANDS | MINIBOSS | - | - | - |
| WANDS | BOSS | - | - | - |

## What the corpus supports

Boss bows have the strongest directly comparable ranged sample: 21 item files per difficulty from 13 packages. Their Power medians are 4/5/7, and Unbreaking medians are 3/4/5. Boss sword Sharpness medians are 5/6.5/8.5. Boss mace Sharpness medians are 5/6/8. These values exceed the ordinary procedural generator's intended range and support dedicated baseline profiles.

Matched variants tell a related but different story. Boss bow/sword/mace/spear pairs commonly add two damage-enchantment levels on hard and four on mythic relative to their own normal variant, while durability usually adds one/two. The median of paired differences differs from the difference of group medians because the underlying distributions and matched subsets differ. Both are retained in the JSON report.

Trash and miniboss samples are much thinner. Bosses dominate modern mace/spear coverage; several trash groups are empty, and several miniboss groups contain only one or two items. Do not extrapolate a one-item outlier into the default for an entire class. Use corresponding sword/bow behavior as an explicit fallback and let administrators override it.

Difficulty-neutral content includes Yggdrasil and older adventure/shrine items. It must remain a separate evidence set. Unusual legacy combinations include Sharpness on bows, Flame on crossbows, and enchantment levels beyond native caps. Preserve fully authored items, but only map a baseline enchantment onto a new weapon when its effect is actually implemented.

## Proposed default formula

For a supported enchantment in a sufficiently sampled group, use `floor(medianPositive + 0.5)` as its level and observed prevalence rounded to the nearest 5% as its secondary occurrence chance. Guarantee the primary damage enchantment for baseline weapons. Use at least five positive samples before treating a group as independently estimated; otherwise fall back to the documented closest supported weapon family and rank. Keep every selected level/chance explicit and editable in the generated YAML.

Enforce nondecreasing strength across normal/hard/mythic for the same item rule. Do not multiply these enchantment levels by combat level: scalable authored items retain their authored enchantments while item level determines the combat baseline. Keep native/implemented-effect caps for binary enchants, projectile-count changes and movement, while preserving the plugin's supported elite levels for damage and durability.

Wands/staves inherit the bow Power and durability baselines. Multicast, blast radius and ignition replace arrow-specific effects with their own configured levels and rarity; they have no observed DLC median and must be labeled as deliberate new balance defaults. Crossbows use their supported ranged equivalents. Maces/spears/scythes use their observed damage levels where supported and sword fallback for sparse ranks. Exact generated profiles are implementation work, not yet shipped by this report.

## Reproduce

From the EliteMobs repository:

```powershell
python design/tools/analyze_dlc_loot.py ../dlc/private-state/generations/20260907T031342379Z-d4164626b272-61c37e91 design/loot-analysis
```

`corpus.json` contains per-package inventory, exclusions, unresolved references, full medians and paired differences. `observations.json` contains source paths, rank/difficulty provenance, chance and authored enchantments. `medians.csv` is the compact table for the manual review. This is source analysis, not observed drop-frequency or gameplay verification.
