# Shared enchantments and authored items

MagmaCore owns provider catalogs, versioned custom-enchantment storage,
Minecraft-style tooltips, ordinary anvil transfer, Lua and owned action cleanup.
FMM owns models, authored wand/staff items, casting and its sixteen definitions.
EM owns its thirteen effects, combat attribution, enchanter economy and Soulbind.
Install matching EM and FMM builds; each shades MagmaCore.

## Configs and enchanting

Administrator-authored item configs supersede level and compatibility limits
for native and custom enchantments. IDs must exist, levels must be positive,
and providers must be available. The actual configured values are retained.
Limits apply when enchanting. The ordinary anvil uses equal-level progression;
EM retains additive progression and its economy. Neither uses the authored
bypass. EM native/full-level overflow keeps its existing owner.

Custom maxLevel is an enchanting cap, not a runtime ceiling. Lua receives the
actual item level. Per-level parameter lists retain their final authored value
above their final row; formulas can express further scaling. Equipment slots
and hooks determine where effects run. Supplied scripts retain their explicit
gameplay conditions, including Earthquake/Plasma Boots mutual exclusion.
Administrators can change those definitions and scripts.

## Content and ownership

Provider files live in plugins/EliteMobs/enchantments/ and
plugins/FreeMinecraftModels/enchantments/. Each YAML definition names one Lua
file. Items use IDs such as elitemobs:hunter and freeminecraftmodels:multicast.
FMM native declarations use minecraft:*; EM keeps its native declaration owner.
Old custom IDs, Java effects and inventory readers are retired. No inventories
are ported. Soulbind remains UUID/prestige ownership metadata.

Defaults install only when the entire provider directory is absent. Existing
installations need retired definitions removed and replacement YAML/Lua files
supplied explicitly. Reload does not overwrite administrator files or recreate
deleted defaults. Duplicate basenames use the shared first-file/warning policy.

EM retains multicast.yml, blast_radius.yml and ignition.yml host settings for
procedural generation probabilities. These do not implement effects; FMM's
provider files own effect values. Multicast defaults remain 2 missiles at 75%,
2 at 85%, and 3 at 70%. Blast Radius and Ignition use their FMM Lua queries.
Actual enchanted books replace Enchanted Source markers. Consumable roles use
EM's consumable section, not fake enchantment levels.

## Supplied EM effects

Loud Strikes, Critical Strikes, Drilling, Ice Breaker, Summon Wolf, Summon
Merchant, Flamethrower, Lightning, Hunter, Earthquake, Plasma Boots, Grappling
Hook and Meteor Shower are provider YAML/Lua definitions.

Hunter counts armor and both hands, adding 5% per level to the existing natural
spawn calculation. Earthquake sums eligible armor; Plasma Boots reads boots.
Both retain double-sneak within ten ticks and a two-minute cooldown. Their
landing deadline is ten seconds. Plasma's eight projectiles per level use the
canonical shared physical projectile engine.

Grappling Hook reads actually consumed arrows, waits up to ten seconds for a
TARGET attachment, pulls for up to ten seconds, then supplies three seconds of
owned slow falling. Invalid worlds, blocked/protected movement and lifecycle
termination abort and restore owned state.

Meteor Shower consumes one item on accepted main-hand right click. The storm
lasts ten seconds with a two-second windup. Native fireballs have an owner and
expiry. Native explosion events remain available to protections, including
EM's explosion block flag. Secondary damage uses captured source facts and
accepted normal damage events. Supplied hostile effects exclude players,
allies, owned pets and protected targets.

## Evidence

Current verification is Java compilation, deployable packaging and Lua
compilation. Runtime, visuals, economy and third-party protection acceptance
are deferred by the user. No inventory migration, publication or production
deployment is included in this checkpoint.
