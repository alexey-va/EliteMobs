# Magic weapon enchantments

EliteMobs uses FMM's capability-4 magic weapon API for these mechanics. Install
the matching FreeMinecraftModels and EliteMobs tester builds together. FMM owns
casting, flight, collision and damage application; EliteMobs reads its usual
enchantment tags and supplies the per-cast modifiers.

| Enchantment | Weapon | I | II | III |
|---|---|---|---|---|
| Multicast | Wand | 2 bolts, 75% each | 2 bolts, 85% each | 3 bolts, 70% each |
| Blast Radius | Staff | +15% radius | +30% radius | +45% radius |
| Ignition | Staff | 2 seconds of fire | 3 seconds | 4 seconds |

Multicast's total potential output is 150%, 170% and 210% of one normal bolt.
Each bolt selects a different eligible target when possible, ordered by the
existing elite/mob/player priority and aim score. With fewer targets than bolts,
targets are reused. Each bolt collides independently with terrain and entities.
Multiple bolts hitting one target each resolve damage, with its previous
invulnerability timer restored afterward. Wand knockback remains zero.

Blast Radius increases radius, not direct-hit damage. The existing radial damage
falloff and line-of-sight checks still apply. The explosion draws its actual
outer radius. Ignition requires an accepted damage event and an uncancelled
combust event. It refreshes fire duration instead of stacking it and never
places fire blocks. Fire damage follows the server's normal burning behavior.

Configure the usual enchantment files under `enchantments/`:

```yaml
# multicast.yml
isEnabled: true
maxLevelV2: 3
maxEnchantmentLevel: 3
isEnabledForProcedurallyGeneratedItems: true
damageMultiplier:
  level1: 0.75
  level2: 0.85
  level3: 0.70
generationChance: 0.35
levelThreeChance: 0.01
levelThreeMinimumItemLevel: 75
```

`blast_radius.yml` exposes `radiusIncreasePerLevel` and `generationChance`.
`ignition.yml` exposes `baseFireTicks`, `fireTicksPerLevel` and `generationChance`.
Effects have hard implementation limits of level III, twice the base radius,
six blocks final radius and ten seconds of fire. Do not advertise higher levels
by changing the configuration cap; upgrades beyond the implemented level fail.

Ordinary procedural custom-enchantment rolls respect the global
`customEnchantmentsChance`. Magic enchants begin at item level 10. Multicast II
can roll from item level 35, and III additionally requires its rare roll and
minimum item level. Blast Radius/Ignition can reach II at item level 30 and III
at 65. Automatic class-loot profiles have their own explicit level/chance rules.

The normal enchanter accepts these built-in books:

- `enchanted_book_multicast.yml`
- `enchanted_book_blast_radius.yml`
- `enchanted_book_ignition.yml`

They use `ENCHANTED_SOURCE,1` and the usual custom-item path. Add them to an
authored reward table like any existing enchantment book. For example:

```yaml
uniqueLootList:
  - filename: enchanted_book_multicast.yml
    chance: 0.02
```

For a fully authored wand, use `MULTICAST,1` in its `enchantments` list. For a
staff, use `BLAST_RADIUS,1` and/or `IGNITION,1`. Explicit weapon identity is still
required. `proceduralEnchantments: true` also rolls compatible magic enchants
through scalable/fixed custom-item construction while retaining authored levels.

Punch is excluded from magic-item construction, generated loot and upgrades.
Legacy Punch is removed when a magic weapon is used. Multicast books reject
staves and ordinary weapons; Blast Radius and Ignition books reject wands and
ordinary weapons. Unsupported upgrades return the ingredients without charging.
Existing Power, Unbreaking, Mending and Vanishing remain generation-compatible.

Compilation and startup checks do not verify the visual presentation, collision,
damage totals, protection integration or enchantment balance. Those remain in
the manual acceptance checklist.
