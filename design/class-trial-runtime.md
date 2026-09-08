# Authored trial runtime: implementation proposal

This proposal covers authored encounters using the existing Lua boss runtime.
The encounter catalog is complete at the first design-pass level; replacement
scripts have not been implemented or deployed.

## Implementation approach

The trainer NPC stays outside the arena and handles enrollment through the class
menu. The challenger is the only player admitted to the arena. A separate trial
boss fights that challenger; any helpers or props belong to the encounter. The
trainer NPC does not move into the arena or become the boss.

Use authored Lua boss powers on the existing EliteMobs/MagmaCore runtime. Keep
admission, fees, class prerequisites, exclusive container reservation and victory
activation in `ClassChallengeInstance`. Replace `ClassTrialCombat`'s generic
player-effect conversion with the authored encounter scripts.

No shared-runtime redesign, new encounter-scope API or general target-filtering
system is a prerequisite. The earlier approval request for that work is withdrawn.
Scripts target the known challenger, trial boss and their explicitly referenced
helpers or props through existing targeting operations. The arena's existing
solo admission and mutual exclusion remain responsible for who can enter.

This is preferable to adding more cases to `ClassTrialCombat`: the fights need
ordered choreography, interruptible channels, object dependencies, shared damage
budgets and conditional phase behavior. Those are scripts with state, not
conversions of `AbilityFamily` and `AbilityEffect` flags.

The existing Lua implementation exposes EliteMobs damage, zones, targeting,
particles, entity operations, hooks and owned scheduled callbacks. Use those
operations for the authored sequences. If implementing a specific mechanic
reveals a missing operation, identify that mechanic and the exact missing
capability, then make the smallest appropriate addition to the existing system.
Do not invent infrastructure in anticipation of a gap.

## Source findings

These findings came from current local source inspection:

- `ClassTrialCombat` selects a player `FixedAbilitySpec`, cycles three slots,
  shows the same circle, and derives cooldown from resource cost. Its projectile
  cases resolve through a distance check. This is the rejected implementation.
- `ClassTrialDefinition.boss()` creates an unequipped Husk for every class and
  supplies root-wide dialogue. There is no authored encounter asset to load.
- `LuaPowerManager.registerLuaPower` validates source through the canonical
  `EliteMobsScriptProvider`, accepts source text, and returns a closeable exact
  registration. `LuaElitePower` supports explicit runtime start and close.
- `ScriptableBoss` uses MagmaCore `ScriptInstance` for VM lifecycle, hooks,
  scheduled callbacks and shutdown. It supplies damage, target, death, phase
  and spawn hooks. Reimplementing that lifecycle in a trial timer is unnecessary.
- `LuaPowerScriptApi` exposes zones, target resolution, relative vectors,
  damage, facing, pushing and particles. `LuaPowerEntityTables` exposes damage
  event mutation and entity operations. These are reusable action mechanisms.
- `LuaElitePower.closeRuntime()` calls `ScriptInstance.shutdown()`; scheduled
  work created through the owned scheduler already has a shutdown path.
- `LuaWorldTableBuilder` gives some spawned entities an expiration through
  `GameClock`. Expiration is distinct from ending a trial early: the encounter
  must explicitly remove any surviving temporary objects when it ends.
- Custom bosses already track reinforcements and cull them. Reuse that parent
  relationship for elite helpers. Keep references to other temporary entities
  so the encounter's cleanup can remove them as well.
- `ClassChallengeInstance` already cancels combat work, closes combat, removes
  the trial boss and releases the arena during teardown. Wire the Lua encounter
  and its temporary entities into that existing sequence.

These observations do not establish that every needed Lua operation is already
available. The implementation must inspect the exact projectile, equipment,
pose, target and cleanup operations before selecting or extending them.

## Encounter state and cleanup

Keep attack phases, cooldowns, finite healing allowances and per-cast hit budgets
in the encounter's script state. Use the existing damage hooks and damage
pipeline for their effects. Multi-hit attacks must respect their stated total
damage cap; redirected damage must not repeatedly redirect the same hit. These
are requirements of the individual mechanics, not a proposal to redesign the
global damage pipeline.

At the end of a trial, stop its Lua powers through their existing shutdown path,
cull its reinforcements, remove any remaining projectiles, props and mounts, and
release its temporary effects before releasing the arena. Handle victory, defeat,
disconnect and cancellation through the same cleanup. An entity's timed expiry
does not replace this early-exit cleanup. Repeated cleanup must be harmless.

Use the trial's existing teardown and reusable script helpers to implement that
behavior. No new public runtime scope or separate trial scripting engine is
planned. Yggdrasil is a content reference; its DLC and the behavior of unrelated
bosses are outside this implementation.

## Content contract

Each form needs an explicit, validated encounter asset containing:

- Canonical form ID, level source, theme, skin key, actual equipped items,
  movement/aim policy and normalized health/damage settings.
- Signature, utility and inherited mobility timelines, with separate windup,
  commitment, active window, recovery and cooldown. Cooldown begins after the
  sequence finishes; player resource cost is not read to invent it.
- Intro, phase, successful assessment, fallback failure and mechanic-specific
  feedback. Intro and phase lines run once. Feedback is selected by the actual
  event, not a random accusation about the player's last action.
- Actor/prop definitions with finite count, reachable geometry, health in
  normalized matched-damage equivalents, no drops/XP, and explicit teardown.
- Phase entry conditions, ordering, and fallback when an actor has been defeated
  or a safe destination cannot be found. No runtime generic fallback attack.

A small shared Lua support library may implement drawing a cone, waiting through
a cast, spending a hit budget or spawning a tracked focus. It must not determine
an encounter by looking at player ability flags. Every form explicitly chooses
the actual order, geometry, sound, dialogue, conditions and outcomes.

Load and validate all 75 authored assets before accepting any class trial. A
missing script, unknown operation or missing equipment reference is an admission
failure before payment, with an administrator diagnostic naming the exact form
and asset. Do not silently replace it with an unequipped generic boss.

## Arena, timing and presentation constraints

The inspected live Wood League configuration has corners `(257,69,333)` and
`(181,91,257)`, start `(219.5,71,295.5)`, and north spawn `(219.5,71,273.5)` in
`em_adventurers_guild`. This proves container coordinates, not interior cover,
headroom or every traversable tile. It is why none of the designs require cover.

Build movement and prop placements relative to validated arena ground. Check
body/headroom and swept travel for horse charges, leaps, dashes and blinks. A
bounded destination is insufficient if the route crosses a wall or leaves the
container. Route failure produces a visible fizzle and recovery, not a teleport
through terrain. Helpers use the same physical containment and target the
challenger. Ephemeral walls are entity/projectile interactions, never edits
to the shared arena's saved blocks.

Warnings and damage must share the same geometry instance and committed target
snapshot. Damage does not independently reconstruct an approximation of a visual
circle/cone/line. Projectiles still resolve by collision, including intervening
entities, rather than assuming a preview line has dealt damage. Keep particles
at borders and important motion points; skip per-frame full-volume sampling.

Use one cast clock and bounded actor/prop collections per encounter. Poll
proximity relationships at a modest fixed interval, with precise projectile
collision handled by the projectile mechanism. No fresh full-world scans every
tick and no unbounded particle tasks per point. Display state is per run;
restoring a temporary status must not erase an unrelated effect applied later.

Death prevention and redirection run in the canonical damage sequence. They
must preserve attacker attribution, normalized damage, protection cancellation,
the class's damage type and one-time victory dispatch. A transferred hit must
not become a new full-strength normalized hit or trigger the same transfer twice.

## Implementation and acceptance order

Implement the five root encounters first on the existing runtime: ranged weapons,
melee arcs, mount/leap/blink paths, a finite ward and an interruptible ally heal.
This establishes working examples for the branch scripts. Do not declare the other 70 replaced
or deploy them with a generic fallback while completing that slice.

Then implement branches by their actual mechanics: interception/formation,
committed heavy attacks and finite survival, projectiles/traps, support
relationships, and magic/summons. The five linked documents remain the review
reference until their values migrate into executable assets; do not maintain
two drifting canonical balance configurations indefinitely.

Current authorization permits compilation and the normal tester deployment
workflow. It does not permit launching a new Autotester run, repository tests
or a real client. The following are **required behavioral acceptance cases to
run when that verification is authorized**, not claims that they have passed:

- Ranger visibly draws and fires a bow; arbalist visibly loads/fires a crossbow.
  Center and outer model hitboxes, melee, wand, staff and projectile attacks all
  damage the intended trial boss/prop/attendant through the normal pipeline.
- A late dodge avoids a committed projectile, terrain/another entity stops it,
  and collision damage cannot exceed the cast's shared cap. No native contact
  hits appear during a stated preparation, arrival or recovery.
- Each warning footprint matches actual danger; every safe gap stays safe.
  Slow/displacement never makes the next warned heavy hit unavoidable.
- Interrupt, shield break, tether break, prop destruction and missed-shot
  branches produce the specified outcome and the promised recovery window.
- All healing, summons and death prevention exhaust their finite budgets;
  waiting, spacing or objective work can answer defenses without a DPS gate.
- Ending, quitting, dying, aborting and reloading during each kind of cast leaves
  no actors, missiles, statuses, tasks or reservations behind. The next Wood
  League run starts cleanly, and the trainer NPC remains outside the arena.
- Entry fees, level and parent mastery prerequisites, solo exclusivity, victory
  unlock/activation, title and audio cue remain intact through the replacement.
- Matched-equipment recordings establish duration, damage pressure and resource
  sustainability for all five root families at each encounter's required level.
  The specified numbers remain provisional until those recordings exist.

A successful compile verifies only the code compiles. A clean startup verifies
only registration/startup. Neither is evidence of Yggdrasil-level presentation
or of a fair, enjoyable fight.
