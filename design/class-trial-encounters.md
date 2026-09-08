# Class trial encounter redesign

Status: first complete authored design pass for all 75 catalog forms (five roots
and 70 branches). The existing generic `ClassTrialCombat` is rejected. These
documents do not establish that any replacement encounter has been implemented,
played, balanced, or visually verified. The current testbed still runs the old
encounter implementation; this design checkpoint is not a deployment.

## Catalog

- [Five root trials](#root-trials-the-standard-the-branches-must-meet)
- [14 Paladin branches](class-trials-paladin.md)
- [14 Berserker branches](class-trials-berserker.md)
- [14 Ranger branches](class-trials-ranger.md)
- [14 Cleric branches](class-trials-cleric.md)
- [14 Spellcaster branches](class-trials-spellcaster.md)
- [Runtime integration and verification proposal](class-trial-runtime.md)

The canonical identities, skill names and weapon affinities come from
`BuiltInClassDefinitions`. These are opponent adaptations of those themes,
not promises that the player versions gain boss cooldowns, telegraphs or new
effects. Player abilities currently use resource costs, not cooldowns.

## Reference and the defect being corrected

Inspected the local Yggdrasil v7 boss scripts, especially Loki's `DodgeRings`,
`CloneSelfChallenge`, `UseBeamAttackVisual` / `UseBeamAttack`, and Jotun Norve's
`UseIceAuraPrep` / `UseIceAura`. The source is the immutable DLC generation
`20260907T031342379Z-d4164626b272-61c37e91/yggdrasil-realm_v7`.

These sequences synchronize an identifiable preparation, sound, animation or
particles, a committed attack, and recovery. Loki's dialogue participates in the
mechanic: it announces the clone challenge, counts down, acknowledges success,
and reacts differently to failure. Jotun's rising frost is an actual windup into
a persistent hazard. The transferable standard is this coordination and readable
counterplay, not their encounter size or their punitive damage values.

The rejected trials use a Husk for every trial boss, no authored equipment,
one red circle for unrelated attacks, resource cost as an invented cooldown,
immediate radius damage in place of projectiles, root-wide repeated dialogue,
and unconditional healing in place of support mechanics. Changing numbers or
adding particles to that dispatcher does not address the problem.

## Shared encounter contract

- The trainer NPC remains outside the arena and opens the enrollment menu.
  The challenger is the arena's only player and fights a separately spawned
  trial boss. Dialogue below belongs to that boss; it does not imply that the
  trainer NPC enters the arena. The root trial titles do not reuse trainer names.
- One human challenger. Training partners, constructs and summons are allowed
  only when a specific lesson needs them; they belong to the encounter and do
  not turn the run into a multiplayer challenge.
- Teach the prospective class's mobility, signature and utility. Counterplay
  must remain possible using movement, ordinary attacks, cover and target
  selection. Never require the ability being unlocked to pass its own trial.
- Defeating the trial boss is the success condition. Objectives create openings
  or stop a trial boss advantage; they do not silently replace the duel.
- Use the existing EliteMobs power, damage and presentation mechanisms. Author
  attack timelines explicitly. No runtime conversion from player effect flags
  to a guessed boss attack.
- Equipment is visible and functional. Archers carry and shoot bows; crossbow
  branches carry crossbows; mace, axe, sword, spear, scythe, wand and staff users
  carry their actual weapon. Shields and temporary implements are deliberate.
- Human disguises need visible preparation: face the target, draw or swing the
  weapon, hold a casting pose, move to a firing position. Do not request custom
  model animations which these player disguises do not have.
- Small amber ground outlines mean an impending hazard. The class's accent
  color identifies the effect. Gold/white readable shapes identify beneficial
  or interruptible objects. Shape and motion must carry meaning independently
  of color. Avoid filling the camera with opaque particles.
- Each attack has authored windup, committed targeting, active duration,
  recovery, and cooldown. Cooldown starts when that attack ends. Normal attacks
  stop during major preparations and explicit recovery windows.
- Aimed projectiles stop tracking before release. Arrows and bolts collide with
  terrain and entities. A drawn warning must agree with the actual hit area.
  Persistent zones have a clear expiration. No invisible damage outside it.
- Root windups are normally 1.2–1.8 seconds; specialization windups 1.0–1.6;
  mastery windups 0.9–1.4. Heavy finishers always get at least 1.5 seconds.
  Difficulty comes from combinations and decisions, not unreadable speed.
- Root fights aim for 45–90 seconds at matched equipment; specializations for
  60–110; advanced/mastery fights for 90–150. These are balance targets, not
  measured results. A five-minute failsafe remains an abort, not an enrage.
- Damage values use fractions of the trial boss's normalized ordinary hit:
  light 0.35–0.55, standard 0.65–0.9, heavy 1.1–1.4. Multi-hit attacks get a
  shared hit budget. No full damage once per particle or per tick.
- No chain crowd control. A damaging displacement grants a brief follow-up
  grace period. A rooted player cannot simultaneously be required to evade an
  unavoidable heavy strike. Avoid blindness in these instructional encounters.
- Healing has a finite encounter budget and an answer. Interrupt a channel,
  separate a tether, destroy its source, or deny its ground. A lone healer must
  not create an endless damage-per-second check.
- Every phase change is announced once and waits until a safe boundary. Do not
  stack a new phase attack over a previous unescapable attack.
- Four authored voice beats per form: opening lesson, escalation, successful
  assessment, constructive failure. Add short attack cues only when useful.
  The trial boss gives feedback as a sparring examiner; the trainer NPC stays outside.
- Dialogue is event-driven, not an ability-name announcement every few seconds.
  Show opening and phase lines once, use at most one short teaching cue per
  mechanic's first demonstration, and select failure feedback from the mechanic
  that actually defeated the challenger. A default written failure line is a
  fallback, not a claim about what the player did. Do not interrupt critical
  telegraphs with titles or send the same mid-fight speech every rotation.
- On exit, death, disconnect, cancellation or success: cancel cast timelines,
  remove projectiles and temporary objects, release modifiers and control,
  remove helpers, then release the shared arena. Nothing can hit the next run.

## Root trials: the standard the branches must meet

### Paladin — The Oath Holds

**Equipment and posture.** Mace and shield, gold-accented plate. Walks deliberately
between short melee exchanges. Divine Steed is a visible saddled, armored horse,
not a velocity change applied to the trial boss's feet.

**Provoke, 12-second cooldown.** The boss plants his shield and strikes it once.
A 4-block gold ring and a low shield note build for 1.3 seconds. For the next
3 seconds he guards his front, takes 60% reduced frontal damage and turns
slowly. The player can go around him; rear hits break the stance. If the player
keeps hammering the shield, he answers with a clearly drawn 70-degree mace
sweep (0.65 hit) after a further 1-second warning. Missing that sweep leaves 2 seconds of
recovery. Lesson: taunt/defense creates a position and an opening, not invincibility.

**Repulse, 15-second cooldown.** Two descending bell notes and a 3.5-block ring
warn for 1.4 seconds, then a single outward pulse deals 0.45 hit and modest
horizontal displacement. Leaving the ring avoids it. No launch into the roof,
no repeated pulse damage. Recovery 1.5 seconds.

**Divine Steed, 20-second cooldown.** Summon/board for 1 second, then show an
8-block charge lane for 1.5 seconds. The lane stops tracking for the final
0.6 seconds. Charge once (0.75 hit, one collision per cast), dismount, and recover
for 2.5 seconds. A miss exposes the boss to 20% extra damage during recovery.
At 50% health he demonstrates
Repulse followed by the charge, with 2 seconds to recover footing between them.

**Voice.** Opening: “A shield buys time. Show me what you do with it.”
Escalation: “Good. Now hold your nerve when the line moves.”
Success: “You found the opening without abandoning your ground. Take the oath.”
Failure: “You watched the shield and missed the rider. We can practice again.”

### Berserker — Fury With a Purpose

**Equipment and posture.** Heavy axe, exposed fur-and-leather silhouette. Strong,
spaced melee swings; she does not move like a fast zombie continuously touching
the player. Her recovery is as visible as her aggression.

**Crater Leap, 18-second cooldown.** Crouch, a gravel crack, then a 3-block
landing circle held at the player's captured position for 1.5 seconds. Actual
ballistic leap, one impact of 0.9 hit, and an outward debris ring. Landing has
2.2 seconds of fatigue; stepping out and returning is the intended answer.

**Rampage, 16-second cooldown.** Three rising drumbeats over 1.5 seconds. Four
seconds of three separately telegraphed axe advances, alternating left and
right cones, 0.55 hit each with a total combo budget of 1.1 hits. She then pants for
2.5 seconds and takes 20% extra damage. Running in a straight line is worse
than reading the sweep and stepping around her flank.

**War Cry, 14-second cooldown.** An expanding hollow ring warns for 1.2 seconds;
the pulse applies 0.5 seconds of mild Slowness only at its edge and does no damage.
It does not cancel arbitrary plugin abilities or turn the player's camera. At half health she uses
it before Rampage, but the first axe swing still receives its full warning.

**Voice.** Opening: “Anyone can swing angry. Show me you can stop.”
Escalation: “There! Keep that fire. Keep your head, too.”
Success: “You waited for the right swing. Now make it count out there.”
Failure: “You chased every opening, even the ones I hadn't given you yet.”

### Ranger — Between the Shots

**Equipment and posture.** A visibly drawn bow, leather hunting gear and quiver
skin. Functional ranged attacks; no unarmed Husk melee. Maintain 7–12 blocks,
reposition along the arena, and stop to draw. No retreat outside the container.

**Volley, 10-second cooldown.** Draw for 1.3 seconds with a rising bow note and
three narrow lanes. Fire a physical three-arrow fan with a deliberately open
gap, 0.45 hit per arrow and at most one hit from that fan. Track until 0.6
seconds before release. Put the bow down for 1.5 seconds afterward.

**Hunter's Mark, 16-second cooldown.** A hawk note and an eye-shaped gold tell
announce a 6-second mark. Marked shots gain 10% damage; avoiding the next complete
fan clears it. Breaking line of sight for 1 second also clears it if cover is
available, but open-ground play never requires cover. Clearing it earns the
one-time line “There. Empty air.” and 2 seconds without a shot. The live arena
configuration establishes bounds, not proof of available interior cover.

**Windstep, 14-second cooldown.** Leaves stream toward the destination for
0.8 seconds, then a bounded lateral dash of 4 blocks. Never dash directly
through the challenger. The next draw still takes the full 1.3 seconds.
At 50% health he follows Windstep with two staggered fans, alternating the safe
gap; the second release has a separate 1.3-second draw and bow note. Each fan can
hit once; both together have a 0.75-hit cap including the mark bonus.

**Voice.** Opening: “Watch the bow. Move when I commit, not when I look at you.”
Escalation: “You've found the gap. Let's see you find the next one.”
Success: “You read the shot before it left the string. Welcome to the trail.”
Failure: “You tried to outrun the arrow. Make me aim at where you used to be.”

### Cleric — A Place to Recover

**Equipment and posture.** Mace, white-and-gold robes, gentle chime and feather
effects. Deliberate short melee exchanges. A single sparring acolyte is used
only to demonstrate ally support; it deals light, spaced damage and cannot respawn.

**Sanctuary, 20-second cooldown.** Draw a 3.5-block white-gold floor sigil for
1.5 seconds. It lasts 6 seconds and heals only encounter allies in visible
pulses, one-quarter matched hit per second per recipient.
The boss's total healing budget is 12% of initial boss health across the fight.
The player can lure the acolyte out and pressure the boss outside the sigil.
The healing source is shown at its center; crossing it does not harm the player.

**Mend, 14-second cooldown.** A 2-second visible tether from the boss to the injured
acolyte, restoring one matched hit, or to herself at half that strength if it
has fallen. Two ordinary
matched hits during the channel interrupt it. The interrupted tether breaks
with a glass chime; the boss pauses for 2 seconds. No instantaneous hidden heal.

**Guardian Flight, 18-second cooldown.** A feather path identifies a sanctuary
or ally before a 1-second flight. The boss cannot immediately heal on arrival;
there is a 1.5-second landing window. At 50% health she uses Flight to demonstrate
moving support to a threatened ally, then gives the player an interruptible Mend.

**Voice.** Opening: “Watch where healing comes from. You can answer it without haste.”
Escalation: “Well timed. Now follow the light to the one who needs it.”
Success: “You saw the whole fight, not just the person before you. That is the gift.”
Failure: “Take a breath. You can step out, choose your moment, and begin again.”

### Spellcaster — The Space Between Spells

**Equipment and posture.** Wand in the casting hand; the staff appears for ward
preparation. Arcane violet and pale cyan, with quiet casting notes escalating
into a single release. Ranged caster movement, not contact melee.

**Arcane Bolt, 7-second cooldown.** A point of light gathers at the wand for
1.2 seconds. A narrow line shows the committed direction for the final 0.5
seconds. A physical, terrain-blocked bolt travels at a dodgeable speed, deals
0.65 hit, and has no homing after release. Recovery 1.3 seconds.

**Mana Ward, 18-second cooldown.** Three visible runes form over 1.4 seconds.
The ward absorbs a finite amount equivalent to two matched hits for at most
4 seconds. Breaking it produces a clean shatter and 2.5 seconds of exposed
recovery. Waiting it out is slower but valid; it never heals the trial boss.

**Blink, 15-second cooldown.** Mark a safe destination 4–6 blocks away with a
small rising pillar for 1 second, then blink along an unobstructed route.
the Spellcaster trial boss remains visible at the destination for 1.3 seconds before beginning
another cast. At half health he teaches a two-bolt sequence with distinct
releases, then a guaranteed ward-break or recovery opening.

**Voice.** Opening: “A spell has a beginning and an end. Fight in the space between.”
Escalation: “One pattern understood. Now keep it in mind while I add another.”
Success: “You stopped chasing the light and started reading the caster. Good.”
Failure: “You moved at the flash. Listen for the breath before it.”

## Branch progression and supporting rules

Each branch below inherits its root mobility as a secondary repositioning tool,
with that root's warning and recovery rules. It does not inherit an automatic
three-button rotation. Signature, utility, phase order and counterplay are
authored in the linked branch documents. These are design specifications;
executable scripts and gameplay acceptance remain separate work.

Baseline attacks are deliberately modest: melee 0.45 hit at least 2.5 seconds
apart with a 0.8-second raised-weapon tell; ordinary ranged shots 0.35 hit at
least 3 seconds apart with a 1-second draw and 0.4-second aim lock. Boss ability
damage is additional only where a timeline explicitly allows it. Baseline AI
must not sneak in a contact hit while a script is winding up or recovering.
Trial bosses face targets gradually while aiming and stop changing direction at
their stated commitment. Poses and weapon visibility need real-client proof.
Unless a move specifies a longer recovery, non-damaging utility preparations
end with 1.5 seconds without basic attacks or a new major cast. Passive visual
lifetimes can continue through that rest; a heal channel is not treated as passive.

The root mobility cooldown and safe-path contract apply in every branch.
Mobility does not reset another move's cooldown. At 50% health, wait until the
current cast and recovery end, give the phase line, allow 2 seconds of safe
space, then enter the documented sequence. Above half health, demonstrate
signature and utility separately before any combined use. Below half, combine
them only in the documented order. If a required actor, object or safe movement
destination is missing, skip that combination and take its recovery; never
substitute an unannounced generic attack.

Utility damage reductions do not multiply into permanent near-invulnerability.
Only the strongest active reduction applies, unless a specific design says
otherwise. Finite shields are depleted by normalized damage equivalents, not
raw click counts: two matched hits means twice the actual matched reference
damage, so weak rapid hits cannot trivially interrupt everything. The same rule
applies to props and attendants. Their physical hitboxes must be reachable by
melee, wand, staff and ranged attacks; the visible base is the damageable base.
They are not armor stands accepting only one Bukkit damage route.

Effective maximum health is set through the canonical normalized boss scaling.
Start roots at the existing dungeon-boss multiplier of 10, first branches at 11,
second branches at 12, and final branches at 13, then calibrate against the stated
duration targets. Those multipliers are proposals, not measured hit counts.
Reserve time for objectives by lowering trial boss health when helper/prop work
would otherwise exceed the duration target. Root resources/weapon affinities
must be usable in every encounter; no mandatory high-DPS class, shield, jump
skill, unlock-specific heal or interrupt.

Shared sparring actors are proposed at three matched hits of health, 0.2-hit
damage every 3 seconds with a 1-second weapon tell, unless their encounter
specifies another value. They retreat permanently on defeat. Actors summoned
after combat begins cannot deal contact damage on their spawn tick. A visible
spawn-in period of at least 1 second precedes their first attack preparation.
No helper may physically trap the challenger against another collider: cap
simultaneous close attackers at two and let the rest reposition.

Do not silently change actual skins or affinity rules to make a trial boss's
equipment fit. Cleric branches include tridents, spears and scythes according to
their affinities. Battlemage-family blades are visibly conjured magic from a
wand, not an assertion that those classes have physical-sword affinity. The
existing seven selected skin profiles are a starting palette; branch-specific
equipment, stance, focus props and effects must make their roles distinguishable.
The designs do not pretend 75 distinct skins have already been selected.
