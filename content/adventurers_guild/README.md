# Adventurer's Guild class trials

These are editable DLC source files owned by the Adventurer's Guild. They are not
bundled in the plugin JAR and are not regenerated on startup. Merge `custombosses/`
and `powers/` into the Guild package when preparing its next release. Local test
servers use these folders under `plugins/EliteMobs/`.

There are 76 instructor YAMLs under `custombosses/adventurers_guild/class_trials/`,
plus shared boss and actor templates. The disabled `class_trial_base.yml` supplies
shared defaults through normal boss inheritance. Each enabled instructor declares
its own name, level, health, appearance, equipment, dialogue and class association.
All ordinary custom-boss fields remain available. Disabling or removing an
instructor disables its trial; there is no generated replacement.

For example, edit `class_trial_ranger.yml`:

```yaml
extends: class_trial_base.yml
isEnabled: true
name: $bossLevel &6Ranger Instructor
level: '10'
healthMultiplier: 10
mainHand: BOW
chestplate: LEATHER_CHESTPLATE:456549
classTrial:
  class: ranger
  power: class_trial_ranger.lua
  voice:
    opening: Watch the bow. Move when I commit, not when I look at you.
    halfway: You've found the gap. Let's see you find the next one.
    victory: You read the shot before it left the string. Welcome to the trail.
    defeat: You tried to outrun the arrow. Make me aim at where you used to be.
```

`classTrial.class` associates a boss with a class ID. Duplicate enabled associations,
missing powers or invalid metadata make the affected trial unavailable and log a
warning. Admission checks this before charging. Trial entry fees and class prerequisites
remain progression rules, independent of editable encounter health and equipment.

`classTrial.power` names a regular Lua power loaded from `powers/`. It is attached
by the challenge runner with the known challenger and arena context. Do not also
list that same power in `powers:` on the boss, since that would start it a second
time without the trial context. Additional ordinary powers can use `powers:` normally.

`powers/adventurers_guild/class_trials/` holds all 76 Lua timelines. They use
`-- @include shared.inc` and matching `mobility/` and `abilities/` fragments. Includes
resolve relative to the source file and must stay within the entry power's directory.
Cycles, excessive nesting and oversized expanded sources are rejected. `.inc` files
are shared Lua source, not independently registered powers. Change a movement fragment
once to update every instructor that includes it.

Each Lua power has a same-name YAML sidecar with `isEnabled: true` and
`powerType: UNIQUE`. The normal Lua loader reads that sidecar's enabled flag,
classification, effect and cooldowns. Keep these powers UNIQUE so natural elites
cannot randomly receive a trial timeline. Disabling the power disables its trial.

`classTrial.actors` maps Lua actor names such as `WOLF` to normal custom-boss YAMLs.
Each spawned actor receives the instructor's level. Lua can specify its display name
and hit budget; the actor template's health multiplier scales that budget. The
`trialActor.prop` option marks a stationary damageable prop. Prop YAMLs choose their
own carrier and disguise. Changes never mutate the shared configuration object.

`classTrial.magicWeapon: WAND` or `STAFF` applies FMM weapon presentation at trial
startup. Such trials require operational FMM magic support. Disguises use ordinary
boss disguise fields; LibsDisguises is optional, with the configured base mob visible
when it is absent. The current skins remain staff-editable placeholder presentation.

Load changed files through the normal plugin lifecycle when a reload or restart is
authorized. A running attempt keeps its selected content until cleanup. The arena's
physical layout, reservation logic, unlock rules and rewards are unchanged here.

Gribble also belongs to Adventurer's Guild content, despite linking to Goblin Kingdom.
