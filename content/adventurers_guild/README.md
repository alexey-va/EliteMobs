# Adventurer's Guild class trials

These editable files belong to the Adventurer's Guild. They are not bundled in
EliteMobs or regenerated at startup. Package `custombosses/` and `powers/` with
the Guild. Gribble belongs to the Guild too, even though he opens Goblin Kingdom.

The 76 instructors are ordinary custom bosses. Their names, equipment, stats,
appearance and powers use the same YAML as other dungeon bosses. The disabled
`class_trial_base.yml` supplies shared defaults through normal inheritance.

```yaml
extends: class_trial_base.yml
isEnabled: true
name: $bossLevel &6Ranger Instructor
level: 10
healthMultiplier: 10
mainHand: BOW
chestplate: LEATHER_CHESTPLATE:456549
powers:
- class_trial_ranger.lua
cullReinforcements: true
classTrial:
  class: ranger
```

`classTrial.class` is only the association used by class enrollment. Exactly one
enabled instructor must match that class ID, and its level must match the class
admission level. Removing or disabling the instructor makes the trial unavailable.
Entry fees, prerequisites, solo admission, arena reservation and class activation
remain in the existing challenge runner.

Put every power in the ordinary `powers:` list. The normal loader starts its Lua
runtime, dispatches hooks and closes it when its owner is removed. There is no
trial scripting context, separate timeline engine or runtime actor registry.
Powers keep their own cooldowns, channel state and finite healing allowances in
`c.state`, and use the normal owned `c.scheduler` for delayed work.

Each `.lua` power has an enabled `.yml` sidecar with `powerType: UNIQUE`. This keeps
instructor powers out of the random natural-elite power pool. Includes are small
shared abilities or presentation helpers, such as Windstep or Judgment. They are
relative `.inc` files, not separately registered powers or encounter definitions.

Dialogue is authored directly at the relevant ordinary Lua hook or mechanic using
normal player/boss messages. Opening and phase messages are guarded by power state.
No separate dialogue configuration or dispatcher is required.

Companions, mounts and destructible props are normal custom-boss YAML files.
The power names that filename when spawning it, supplies the instructor's level,
and sets `add_as_reinforcement=true`. Their health, damage, equipment and AI come
from their YAML. Props do not use matched-hit budgets or a private prop schema.
The instructor's `cullReinforcements: true` removes its surviving companions,
mounts and tracked ordinary projectiles when the run ends. Timed expiry also
limits projectiles during a fight; it does not replace parent cleanup.

Lua uses ordinary zones, native projectile collision, navigation and velocity.
Damage-sharing powers use the normal reinforcement-damage hook and transfer
operation. Transfers do not repeat offensive scaling or recursively share again;
recipient Lua guards still apply. The supplied amount is the damage at that hook,
not a promise about all later event handlers.

Preparation rejects a missing instructor or inactive required Lua runtime before
charging. A power failure or rejected mandatory summon during a run ends it and
refunds the fee. All shipped references are checked statically; arbitrary later
Lua summon dependencies are not inferred before admission. Inspect console errors
when adding or disabling content. LibsDisguises is optional: the ordinary boss
loader shows the configured base entity when it is absent. Missing custom models
still require their normal model integration to be corrected.

Load changed files only through an authorized normal reload or restart. Source
and syntax checks do not establish gameplay, visual or balance acceptance.
