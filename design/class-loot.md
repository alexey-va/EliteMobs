# Automatic class loot

`classLoot: true` adds a separate baseline equipment roll to a custom mob's death.
It works even when `dropsEliteMobsLoot: false` or the authored loot table is empty.
Existing custom items and unique loot remain available alongside it. New loaded
custom-mob configurations default to coverage enabled; explicit `classLoot: false`
settings are preserved. Summoned reinforcements, mounts and anti-exploit kills
are excluded. A recipient must contribute at least 10% of the mob's maximum HP,
be a real tracked player, and not be locked out of the dungeon reward.

Configure each item's name and lore once in the boss YAML:

```yaml
classLoot: true
classLootRank: BOSS
classLootDifficulty: AUTO
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
  DPS_CHESTPLATES:
    name: "&bIcebreaker's Hauberk"
    lore:
      - "&7The smith sharpened every link."
      - "&7Putting it on requires practice."
  TANK_CHESTPLATES:
    name: "&bGlacier Guard"
    lore:
      - "&7The last avalanche left a dent."
      - "&7The next will have to try harder."
  SHIELDS:
    name: "&bWinter's Door"
    lore:
      - "&7Taken from a cabin buried in snow."
      - "&7It still keeps the cold outside."
```

The active instanced dungeon supplies the difficulty ID. Numeric IDs 0/1/2,
Normal/Hard/Mythic and Easy/Medium/Hard are supported, ignoring case, surrounding
whitespace and color formatting. The package's authored mode declarations determine
whether Hard is the middle or top tier: Easy or Medium selects the latter scheme,
unless the IDs explicitly declare Normal or Mythic. Detection happens before
translation. Numeric IDs always retain their 0/1/2 meaning. A recognized name can
supply the tier for a custom ID, or supply the ID when it is missing.

`ClassLootSettings.yml` maps resolved IDs 0/1/2 to NORMAL/HARD/MYTHIC by default;
an explicit mapping for the original ID takes precedence. Unrecognized definitions
produce a console warning with the package filename. Unknown custom IDs retain
exact matching for authored filters and use an explicit loot mapping or the
configured default tier. Power and loot `difficultyID` filters both accept a scalar
or a YAML list, and accept either numeric or named IDs. Unknown filter values warn
once per package/source/value; empty or malformed filters match nothing.

Outside an instance, the configured
`defaultDifficulty` applies. Set `classLootDifficulty` to a named difficulty for
non-instanced content with a known difficulty. `classLootRank: AUTO` uses BOSS/EVENT
or MINIBOSS boss types, then legacy `$bossLevel` / `$minibossLevel` name tokens,
otherwise TRASH. An explicit TRASH/MINIBOSS/BOSS override avoids ambiguity in older
content. Name/filename classifications in the corpus are evidence inferences;
runtime rank does not guess from filenames.

Supported item keys are SWORDS, AXES, BOWS, CROSSBOWS, TRIDENTS, HOES (scythes),
MACES, SPEARS, STAVES, WANDS, DPS_HELMETS, DPS_CHESTPLATES, DPS_LEGGINGS, DPS_BOOTS,
TANK_HELMETS, TANK_CHESTPLATES, TANK_LEGGINGS, TANK_BOOTS and SHIELDS.
Every available family has equal selection weight. With all 19 available, weapons
occupy 10/19 of the pool, DPS armor 4/19, tank armor 4/19 and shields 1/19.
This guarantees pool coverage, not a full set per kill or a match to the recipient's
current class. An omitted item still participates with `&6$boss's $weapon` and
empty lore. `$boss`, `$weapon`, `$item` and `$difficulty` work in each item's name and lore.
`lore: []` explicitly means no authored lore.

Default drop chances are 5% for trash, 25% for minibosses and 100% for bosses,
per eligible contributor. These are editable v0 economy choices, not frequencies
measured from DLC. Instanced drops enter the existing dungeon vote pool; eligible
party drops use the existing party pool; other rewards use normal personal loot.
Item level comes from the existing combat reward level and item-tier roll.

## Enchantment formula

The generated `ClassLootSettings.yml` contains all 171 difficulty/rank/family
profiles. This excerpt shows the shape of an editable profile; edit the generated
file rather than replacing all profiles with this excerpt:

```yaml
enabled: true
defaultDifficulty: NORMAL
difficultyIds:
  '0': NORMAL
  '1': HARD
  '2': MYTHIC
enchantmentBudgetFraction: 0.5
minimumPrimaryLevel: 1
dropChance:
  TRASH: 0.05
  MINIBOSS: 0.25
  BOSS: 1.0
profiles:
  MYTHIC:
    BOSS:
      WANDS:
        primaryEnchantment: POWER
        enchantments:
          POWER:
            level: 7
            chance: 1.0
          UNBREAKING:
            level: 5
            chance: 0.75
          MULTICAST:
            level: 2
            chance: 0.4
        rareEnchantments:
          MULTICAST:
            level: 3
            chance: 0.01
```

For each rule, roll its chance independently. Rare rules are additional rolls
and replace a successful ordinary rule only when their level is higher. Enabled
native levels become a bag of enchantment units. Draw `ceil(N * fraction)` units
without replacement. Reserve up to `minimumPrimaryLevel` of those units for the
primary enchantment, bounded by its selected ceiling and the total budget. A
zero budget stays zero. Custom enchantments keep their selected levels and do
not consume native units, matching existing scalable custom loot. Global enchant
availability, procedural eligibility and `maxEnchantmentLevel` still apply.
`maxLevelV2` is the ordinary procedural/value reference; it does not truncate the
authored ceilings. Unsupported weapon/enchantment combinations are skipped with
a configuration diagnostic; wands and staves cannot acquire Punch from profiles.

DPS armor uses Sharpness as its primary enchantment with lighter protection.
EliteMobs already counts damage enchantments from equipped armor. Tank armor uses
Protection as its primary, with defensive secondary enchantments. Shields use
Protection through the existing offhand defense calculation. Helmet and boot
profiles can include their supported slot enchantments. These are separate items,
not a new full-set bonus or new skill types. Armor uses diamond materials; shields
use SHIELD. Each slot has its own name and lore under `classLootItems`.

Profiles optionally accept `potionEffects` using the existing item syntax, for
example `potionEffects: ["STRENGTH,0,SELF,ONHIT"]`. Amplifiers are zero-based. These
effects use the existing item effect rules and durations, independently of the
enchantment budget. Invalid entries warn and are skipped. The bundled equipment
profiles have no potion effects: the reviewed samples do not justify making a
particular proc a baseline benefit. Existing weapon profiles remain unchanged;
missing armor and shield profiles are supplied from the bundled defaults.

Example: Power 7 plus Unbreaking 5 creates 12 native units. At 0.5, six are
selected; one is reserved as Power, and five are drawn from the remaining bag.
The resulting item might have Power 4 / Unbreaking 2. Multicast II, when selected,
remains II. Its separate 1% rare roll can produce III on a Mythic boss wand.
That is 1% of generated Mythic boss wands, not 1% of all boss kills. Profiles can
be tuned without duplicating Winter's Edge into three custom item files.

The retained full available DLC snapshot, medians, exact modeled legacy roll
statistics and unresolved references are in [loot-analysis](loot-analysis/README.md).
Native profile ceilings round positive medians to the nearest integer. Secondary
chances round prevalence to 5% increments. Sparse groups prefer the better-sampled
sword or bow equivalent; the exact source family and sample count for each rule
are in `loot-analysis/profile-provenance.json`. Level ceilings never decrease
across difficulties. Binary/mechanically capped effects use explicit caps. Magic
weapons have no classified DLC samples: their base Power/Unbreaking derive from
bows; Multicast, Blast Radius and Ignition chances are deliberate new defaults.
This is a balance baseline for manual review, not measured gameplay acceptance.

## Magic availability and migration

In `ProceduralItemGenerationSettings.yml`, these default to enabled:

```yaml
validWeapons:
  STAVES: true
  WANDS: true
```

These switches control ordinary procedural drops, shops and class loot. Operational
compatible FMM is also required. Selection excludes a missing, disabled or reloading
magic service. Experimental Combat world settings do not gate item availability.
`dropProcedurallyGeneratedItems` controls ordinary procedural drops; class coverage
has its own global `enabled` switch and per-mob `classLoot` switch. Procedural names
come from `staffNames` / `wandNames` in `StaticItemNames.yml`; class item names and
lore remain per mob and per item.

Legacy `classLootNames` and shared `classLootLore` migrate into individual entries.
Existing per-item fields, including empty lore, take precedence. The migration
preserves source text, removes the obsolete fields and uses the normal translated
configuration lifecycle. Translation keys follow paths such as
`classLootItems.SWORDS.lore`. Existing explicit classLoot opt-outs are not overridden.
