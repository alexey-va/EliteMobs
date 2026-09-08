# Baseline boss loot

Configure baseline loot in the boss YAML. `classLoot: true` adds a weapon-family
roll for each eligible loot recipient alongside existing loot. Summoned
reinforcements and mounts are excluded. Normal loot eligibility still applies,
including `dropsEliteMobsLoot` and player damage contribution.

Each generated item has its own name and lore:

```yaml
dropsEliteMobsLoot: true
classLoot: true

classLootItems:
  SWORDS:
    name: "&bWinter's Edge"
    lore:
      - "&7Its edge has never known a whetstone."
      - "&7Each winter leaves it sharper."
  AXES:
    name: "&bGlacier Splitter"
    lore:
      - "&7The haft bears the names of seven miners."
      - "&7None returned for it."
  WANDS:
    name: "&bFrostwhisper"
    lore:
      - "&7Hold it to your ear."
      - "&7The blizzard is still inside."
```

Supported keys are `SWORDS`, `AXES`, `BOWS`, `CROSSBOWS`, `TRIDENTS`, `HOES`
(scythes), `MACES`, `SPEARS`, `STAVES` and `WANDS`. Available families have equal
weight; the roll does not match the recipient's class. An omitted entry remains
in the pool, with the name `&6$boss's $weapon` and empty lore. An explicit
`lore: []` gives that item no authored lore. `$boss` and `$weapon` work in both
the item's name and its lore. Level and supported enchantments are generated
through the standard item pipeline.

On load, the earlier `classLootNames` entries and shared `classLootLore` list
migrate into the individual item entries. Existing per-item fields take
precedence, including empty lore. The old fields are removed from the loaded
boss configuration and saved through the normal configuration workflow. The
migration preserves the source text; it does not write translated display text
back into the YAML. Translation keys now follow each item's path, such as
`classLootItems.SWORDS.lore`.
