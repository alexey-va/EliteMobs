# Automatic class loot

Author equipment as ordinary YAML files under `customitems`, using
`itemType: CLASS_LOOT`. Bosses reference those files through `uniqueLootList`.
The item loader owns names, lore, materials, models, permissions and item identity.
The class-loot profiles own generated difficulty/rank stats. There are no loot
templates in `custombosses`, and no boss-side `classLootItems` format.

For example, `customitems/goblins/borrowed_forever.yml`:

```yaml
isEnabled: true
itemType: CLASS_LOOT
material: DIAMOND_SWORD
name: "&aBorrowed Forever"
lore:
- "&7Goblin signed receipt."
- "&7Receipt says MINE."
```

The boss uses the existing item-reference format:

```yaml
classLoot: true
classLootRank: BOSS
classLootDifficulty: AUTO
uniqueLootList:
- filename: borrowed_forever.yml
  chance: 1.0
```

Only `CLASS_LOOT` entries participate in the single class-selection roll. The
rank profile controls the initial reward chance; a selected entry's `chance`
then remains a probability, never a weight. Its `amount` controls the selected
item's quantity. Permission and difficulty filters apply before selection.
Multiple items in one family share that family's selection probability equally.
`CUSTOM`, `UNIQUE`, `DROPPABLE`, currency and command entries keep their existing
independent behavior. Class items do not enter ordinary random drops or shops.
The existing getloot commands and explicit chest/quest references can generate
them; without a boss context they use the configured default difficulty and TRASH
rank. Profiles supply generated enchantments; explicit item enchantments override
matching generated values, and authored potion effects are retained alongside
profile effects. CLASS_LOOT always scales to the requested reward level.

Weapons infer their family from `material`. Magic items use the existing
`weaponType: STAVES` or `weaponType: WANDS`, with the appropriate material and
optional `fmmItemModel`. Armor must declare its role, for example:

```yaml
isEnabled: true
itemType: CLASS_LOOT
material: DIAMOND_CHESTPLATE
classLootFamily: TANK_CHESTPLATES
name: "&bGlacier Guard"
lore:
- "&7The last avalanche left a dent."
```

Invalid/mismatched families, missing identity fields, and unavailable materials
disable that item with its filename in the warning. `lore: []` is valid. Omitted
families are absent from selection; no placeholder item is synthesized.
Real boss inheritance remains available for behavior, including ordinary inherited
loot lists. Keep item filenames unique across installed content.

Class rewards require `classLoot: true`, the global enable switch, and at least
one eligible referenced class item. They work with `dropsEliteMobsLoot: false`.
Reinforcements, mounts, anti-exploit kills and locked-out players are excluded.
Recipients must be tracked real players contributing at least 10% of maximum HP.

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

Supported families are SWORDS, AXES, BOWS, CROSSBOWS, TRIDENTS, HOES (scythes),
MACES, SPEARS, STAVES, WANDS, DPS_HELMETS, DPS_CHESTPLATES, DPS_LEGGINGS, DPS_BOOTS,
TANK_HELMETS, TANK_CHESTPLATES, TANK_LEGGINGS, TANK_BOOTS and SHIELDS.
The default selection favors the active class: 80% relevant equipment and 20%
off-class equipment. Within the chosen bucket, categories have configurable weights
(WEAPONS 50, ARMOR 45, SHIELDS 5), then available families in that category are
equally likely. Adding a family does not change its category's share of that bucket.
This is one selected item per successful roll, with quantity from the selected
entry's `amount`, which defaults to one. `$boss`, `$weapon`, `$item` and
`$difficulty` work in each custom item's name and lore. Authored names and lore
use the normal custom-item translation path.

Default drop chances are 5% for trash, 25% for minibosses and 100% for bosses,
per eligible contributor. These are editable v0 economy choices, not frequencies
measured from DLC. Instanced drops enter the existing dungeon vote pool; eligible
party drops use the existing party pool; other rewards use normal personal loot.
Item level comes from the existing combat reward level and item-tier roll.

## Class preferences

Personal rolls use the recipient's active specialization. Each shared dungeon roll
chooses one qualifying contributor uniformly, independently of damage beyond the
existing 10% threshold, and uses that contributor's class for selection. Party
rolls do the same within the contributing nearby members of that party. Items
still enter the existing shared vote and are not reserved for the selected player.
The number of rolls, threshold, lockouts and voting eligibility are unchanged.

Weapon relevance comes from `ClassFormDefinition.weaponAffinities`, including
specialization-specific bonuses. It does not use the weapon currently held. Armor
and shield preferences appear for every class in the generated settings:

```yaml
selection:
  classBiasEnabled: true
  relevantChance: 0.8
  categoryWeights:
    WEAPONS: 50
    ARMOR: 45
    SHIELDS: 5
  classes:
    paladin:
      armor: TANK
      shields: true
    champion:
      armor: DPS
      shields: false
    ranger:
      armor: DPS
      shields: false
    battlemage:
      armor: BOTH
      shields: false
```

The explicit tank defaults are Paladin, Guardian, Aegis, Bulwark, Shieldbearer,
Templar, Bannerlord, Deathless, Dreadnought, Colossus and Arcane Knight. Justicar,
Marshal, Juggernaut, Warmonger, Battlemage and Cryomancer accept both armor roles.
Other forms prefer DPS armor, including Cleric forms. Shield preferences default
to Paladin, Guardian, Aegis, Bulwark, Shieldbearer, Justicar, Templar, Marshal and
Bannerlord. These are editable equipment preferences, not combat role restrictions.

Missing class selection or disabled bias uses the category weights without the
80/20 split. An empty bucket transfers its probability to the available bucket.
Unavailable magic/material families are removed before calculating probabilities.
A zero category weight excludes it from real rolls; all zero weights disable
automatic rolls and warn. The weights are relative inside each relevance bucket,
so they are not promises of an overall 50/45/5 distribution for every class.

## Administrator review

Permission: `elitemobs.loot.admin`. Commands require a player and support tab completion.

```text
/em loot preview <mob.yml> <level> <NORMAL|HARD|MYTHIC>
/em loot preview <mob.yml> <level> <NORMAL|HARD|MYTHIC> <AUTO|TRASH|MINIBOSS|BOSS> <family|ALL>
/em loot giveall <mob.yml> <level> <NORMAL|HARD|MYTHIC>
/em loot giveall <mob.yml> <level> <NORMAL|HARD|MYTHIC> <AUTO|TRASH|MINIBOSS|BOSS>
```

For example:

```text
/em loot preview GK_boss_snickersnap.yml 100 MYTHIC
/em loot preview GK_boss_snickersnap.yml 100 MYTHIC BOSS WANDS
/em loot giveall GK_boss_snickersnap.yml 100 MYTHIC
```

`preview` reports presentation issues, family probabilities for the administrator's
active class, authored enchantment ceilings/chances, rare rules, potion effects
and authored table entries. A named family also gives one generated sample.
Short forms use the boss's resolved rank. Explicit rank/difficulty arguments
override it for inspection without modifying its configuration. Family probabilities
are conditional on a successful automatic roll; configured drop chance is reported
separately. Enchantment rules are authored ceilings before budget and global
enchantment availability/caps, not guaranteed values on every sample.

`giveall` gives one independently rolled sample of every available automatic family
and one sample per authored item entry. It bypasses drop chances, relevance weights,
permission conditions and configured quantities. Authored entries include **all
difficulty variants**, with raw difficulty conditions reported: selected difficulty
controls the automatic profiles, and the command makes no assumptions about which
dungeon owns a reusable mob. Fixed and limited custom items retain their existing
level rules; scalable samples use the requested level without the administrator's
progression cap. Unavailable/invalid items are reported; missing generations also
warn in console. Overflow drops at the administrator's feet.

The commands do not spawn a mob, run death events, execute command rewards, pay
currency or create loot votes. Non-item rewards are reported only. A disabled
automatic-loot switch is reported but does not prevent deliberate preview samples.
This is an inspection tool, not a drop-frequency simulation or dungeon loot audit.

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
use SHIELD. Each slot has its own ordinary custom-item file, name and lore.

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
lore remain in `customitems`.

The rejected boss-template formats have been removed, including their automatic
conversion code. Apply the converted DLC patches with the matching runtime.
When upgrading a September 9 staff-review installation, remove exactly the old
template filenames listed in each replacement patch before loading the content.
Translation keys are the ordinary item `name` and `lore` keys. Explicit
`classLoot: false` exclusions are preserved in the converted content.
