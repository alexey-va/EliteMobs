# Ranger branch encounters

> Historical design sketch. The current ordinary YAML/Lua implementation and
> ownership contract are documented in [class-trial-runtime.md](class-trial-runtime.md).
> Mechanics requiring private trial APIs were redesigned; this document is not
> an implementation contract or evidence that those APIs exist.

Authored designs under [the shared contract](class-trial-encounters.md). Nothing
here establishes runtime implementation or balance verification.

All trial bosses visibly carry the weapon named below and use its draw/reload
pose. Bows launch arrows; crossbows launch bolts. Projectile damage comes from
collision, not a radius check at the captured target location. A multi-projectile
cast owns one shared hit budget. Terrain stops all ordinary shots. Piercing may
pass through entities, never solid blocks. Maintain an 8–12-block firing band,
retreat at most once per mobility cooldown, and stop during reload/recovery.
Do not kite the player indefinitely. All fights work on open ground; cover is
an additional option, never an assumed feature of the Wood League arena.

## sniper — Wait for the Commitment

**Equipment and lesson:** longbow, plain leather, still firing stance. The draw
tracks early, commits late, and leaves a long opening afterward.

**Expose Weakness (18s CD):** 1.3s feather spiral, mark for 6s (+15% shot damage).
Avoiding the next Aimed Shot breaks the mark. **Aimed Shot (12s CD):** 2s bow
draw with rising string pitch; the thin aim ray stops tracking for the final
0.7s. Release one 0.95-hit arrow, maximum 1.1 while marked. Recovery 2.8s.
A late lateral step or cover is valid; distance alone does not cancel the arrow.

**Escalation:** Windstep moves laterally after a missed shot, followed by its
full arrival recovery before the next draw. No snap-shot from the destination.
Ordinary shots deal 0.35 hit, at least 3s apart, and stop during the main draw.

**Voice:** Open: “I will follow you until I commit. Learn which moment matters.”
Half: “Another angle. The string will give you the same warning.”
Win: “You moved when the shot could no longer follow. Cleanly read.”
Loss: “You chose a direction before I chose mine.”

## bowmaster — One Flight, One Line

**Equipment and lesson:** bow, spear visibly stowed. A piercing arrow threatens
a line of targets rather than gaining an unexplained explosion.

**Far Sight (20s CD):** 1.3s raised bow marks for 6s, showing an extended aim ray
without increasing damage. **Piercing Flight (14s CD):** 1.8s draw, line fixed
for 0.7s, one 0.9-hit arrow piercing up to three entities. Three paper training
targets along the initial lane split as it passes; they demonstrate penetration
and are not cover. A player hit ends that cast's player damage eligibility.
Recovery 2.5s; moving sideways breaks the line.

**Escalation:** Windstep gives the next flight a diagonal approach. The target
props are reset only outside attack windows, cannot drop items, and never provide
an invisible collider after destruction. Far Sight cannot make the arrow home.

**Voice:** Open: “Three targets can share one mistake. Do not stand in their line.”
Half: “The line has moved. The lesson has not.”
Win: “You saw a flight path where others would see separate targets.”
Loss: “Those targets were pierced. They were never shelter.”

## deadeye — One Perfect Shot

**Equipment and lesson:** longbow, spare crossbow on the back. One highly readable
heavy shot rewards restraint and a precise movement response.

**Spotter's Mark (22s CD):** 1.5s hovering feather reticle, 7s mark. Three visible
notches indicate the upcoming shot's draw stages, not a hidden damage stack.
**One Perfect Shot (18s CD):** 2.4s draw: track 1.4s, lock direction 1s, release
one 1.3-hit arrow. Impact has a sharp single chime, no radius splash. Recovery
3.5s with the bow lowered. The mark adds no damage on top of this heavy value.
Dodging the arrow clears it and exposes the trial boss (+20%) for the recovery.

**Escalation:** Windstep once to a visible flank before marking. No feint or
late tracking on the heavy shot; precision must be trustworthy. Its speed is
higher than root arrows, with the longer committed warning compensating.

**Voice:** Open: “One shot. You will have more than one chance to read it.”
Half: “I have changed the angle, not the promise.”
Win: “A perfect shot still needs someone standing in its path.”
Loss: “The last note of the draw meant the direction was fixed.”

## raincaller — Walk the Dry Ground

**Equipment and lesson:** bow with rain-dark clothing. Area denial uses timed
physical arrows, a safe path, and a finite lifetime.

**Storm Mark (20s CD):** 1.5s feather ring selects the challenger's current ground;
its center then stays fixed. **Arrow Storm (22s CD):** arrows visibly launch
upward, with a 2s warning over a 6-block circle split into three lanes. The
middle lane stays dry for the first 2s; the left lane is warned and becomes dry
for the final 2s. Hazard arrows fall in bounded waves, shared 1.2-hit budget,
and are removed after contact. No damage check covers the safe lane. After
the 4s rain, the trial boss rests 3s.

**Escalation:** Windstep repositions the archer before the next marked storm;
the second safe lane switches right, visibly previewed. Ordinary shots stop
while a safe-lane transition is taking place.

**Voice:** Open: “A storm does not cover every step. Find the dry ground.”
Half: “The wind is turning. Watch where the next gap opens.”
Win: “You crossed the weather instead of racing it.”
Loss: “The feathers showed which lane would clear next.”

## arbalist — The Empty Crossbow

**Equipment and lesson:** crossbow, reinforced leather. Slow pressure and a
deliberate reload; ordinary bow AI is not an acceptable substitute.

**Lock On (20s CD):** 1.5s lens glint, 6s targeting mark. It improves early
tracking only; it never changes the committed bolt. **Breach Bolt (15s CD):**
1.8s braced aim with a 0.7s fixed lane, one 0.9-hit physical bolt. Contact
causes 15% increased damage received for 3s. The trial boss must reload for
3s, so the debuff does not guarantee another unavoidable shot. Dodging the
bolt or crossing behind the trial boss during the reload is rewarded.

**Escalation:** Windstep establishes another firing stance after the reload.
The weapon visibly returns to unloaded state on release. No melee contact
attacks, point-blank triple shots, or projectile penetration through terrain.

**Voice:** Open: “A loaded crossbow commands respect. An empty one asks for time.”
Half: “Another position. You know what the reload costs me.”
Win: “You spent my reload better than I did.”
Loss: “Once the bolt passed, there was nothing left in the crossbow.”

## artillerist — Count the Mechanism

**Equipment and lesson:** repeating crossbow and a visible ammunition cache.
Burst timing and resupply are separate, interruptible advantages.

**Repeater Burst (16s CD):** 1.6s bracing, then four bolts 0.65s apart. Each
locks direction 0.35s before release, 0.35 hit, 1.05 total budget. The trial boss
stands still and cannot turn more than 35 degrees between shots. Recovery 3s.
**Quickload Cache (26s CD):** 1.8s deployment places a two-hit cache, 8s lifetime.
A 2s reload channel beside it can shorten the next burst's recovery to 2s,
never its warning or bolt spacing. Break the cache or deal two matched hits
during the channel to cancel that benefit and gain 2.5s exposure.

**Escalation:** Windstep toward the cache advertises the reload attempt.
One cache at a time; no surprise burst on its destruction.

**Voice:** Open: “Count the mechanism. Four bolts, then work to do.”
Half: “You have noticed the pause. Now notice what I use to shorten it.”
Win: “A fine machine is still only as ready as its supply.”
Loss: “You waited through the reload beside the thing that improved it.”

## dragonslayer — The Braced Heartpiercer

**Equipment and lesson:** heavy crossbow, spear at the back. Two large armored
training effigies demonstrate why one penetrating shot matters against big foes.

**Giant's Mark (24s CD):** 1.5s rune highlights an effigy's exposed center for
7s. Its base glows and is always reachable by ordinary melee. **Heartpiercer
(20s CD):** 2.3s crossbow brace, one lane through the marked effigy and the
challenger, fixed for the final 0.9s. The 1.2-hit bolt penetrates the effigy,
collapses its armor and opens a 3.5s reload. Sidestep the lane; do not hide
behind the marked giant. Breaking the effigy's two-hit base during the brace
cancels the shot and exposes the trial boss (+25%) for the same recovery.

**Escalation:** Windstep takes a new angle on the second effigy. No respawns;
without an effigy the same clearly warned shot has no marking advantage.

**Voice:** Open: “A giant is a large target. It is not always good cover.”
Half: “Watch the brace. That much force needs a stable line.”
Win: “You understood the shot, and the support it needed.”
Loss: “The glowing heart marked the path through, not a place to hide.”

## skirmisher — Across the Fan

**Equipment and lesson:** shortbow, light leather. Moving fire has a readable
travel path and limited turning, not perfect aim while sprinting.

**Running Hunt (18s CD):** 1.3s dashed lateral route, then 4s running at +15%
speed. **Fan Volley (14s CD):** 1.5s bow draw precedes three arrows spread
through a 45-degree fan, one cast budget of 0.85 hit. The fan direction locks
0.6s before firing. It can occur once during Running Hunt. Cross behind the
archer's route or evade the committed fan; recovery 2.5s at the route's end.

**Escalation:** Windstep changes to the opposite lateral route after recovery.
The new side is advertised by the dashed path and bow orientation. Running
Hunt does not add slow or damage amplification on top of the shot.

**Voice:** Open: “Do not follow the bow. Read where the feet are taking it.”
Half: “Other side. Keep your crossing in mind.”
Win: “You crossed my route before my aim could cross yours.”
Loss: “You followed the fan instead of cutting across its path.”

## windrunner — End of the Strafe

**Equipment and lesson:** bow, wind-colored cloak. Sustain comes from movement,
but a deliberate stop gives the challenger a reliable attack window.

**Tailwind (22s CD):** 1.4s pale streamers outline a curved, 8-block running path,
then 5s of movement. **Strafe Volley (17s CD):** three separately drawn arrows
from marked points on that route, 1.2s apart, each with a 0.5s committed aim.
Damage 0.4 each, 1.0 total cap. The arrows use current firing positions, not
invisible launches from the route's start. Crossing inside the curve reaches
the final firing point first. Recovery there lasts 3s; no evasive movement.

**Escalation:** Windstep enters the next curve from its opposite end after a
full 1s destination warning. Do not extend Tailwind when the player closes.

**Voice:** Open: “A swift path still has an end. Meet me there.”
Half: “You found the end once. Read the new curve.”
Win: “You spent fewer steps to arrive at the better place.”
Loss: “Chasing every shot kept you behind every turn.”

## pathfinder — Do Not Follow Blindly

**Equipment and lesson:** bow, spear, one trained wolf. Pack support depends on
a reachable trail and a clear target order.

**Guide's Trail (24s CD):** 1.6s three ground beacons appear along a 9-block
route for 7s; the wolf gains 20% speed within 2 blocks of it. Each beacon takes
one matched hit, and destroyed sections lose their bonus. **Pack Hunt (18s CD):**
1.5s whistle and target mark, then a separately warned wolf pounce (0.45 hit)
and bow shot (0.65 hit) 2s later. Their combined cap is 0.9. Move across the
trail or break the middle beacon to disrupt pursuit; recovery 2.8s.

**Escalation:** Windstep reaches a new trailhead. The wolf is one four-hit
training companion, retreats on defeat and never respawns. Pack Hunt without
the wolf becomes a single marked bow shot with the same full warning.

**Voice:** Open: “A trail helps the pack. It also tells you where we want to go.”
Half: “New trailhead. Do not let the whistle choose your route.”
Win: “You read the trail and gave the pack a harder journey.”
Loss: “You ran along the beacons while we were strongest beside them.”

## tempest_archer — The Returning Wind

**Equipment and lesson:** bow with a visible spiral wind effect at the string.
Arcing shots have predetermined routes rather than hidden homing.

**Gale Mark (22s CD):** 1.4s feather marker and a 6s tailwind advantage; it ends
early when the main shot misses. **Cyclone Shot (18s CD):** 1.8s spiral draw
previews two curved projectile routes around a clear middle corridor. Arrows
follow those fixed curves for at most 2s, each collision checked against terrain
and entities every movement segment. They do not turn after the challenger.
Each is 0.55 hit; shared cap 0.9. Recovery 3s. Ordinary arrows remain straight.

**Escalation:** Windstep rotates the starting position, then the paths are drawn
again for their full warning. The inner corridor stays at least 3 blocks wide;
world clipping shortens a path, never pushes a bolt through a wall.

**Voice:** Open: “Wind bends a flight. It does not make the whole sky dangerous.”
Half: “Read the curves again. Their beginning has moved.”
Win: “You found the quiet air between the flights.”
Loss: “The arrows curved along the trails I showed you.”

## saboteur — The Second Warning

**Equipment and lesson:** crossbow and trap satchel. A landed payload leaves
another warning; direct collision must not cause two full simultaneous hits.

**Snare Beacon (22s CD):** 1.6s placement warning, a visible 2.5-block ring for
6s. Entering slows 20% for 1s, with a per-player 3s trigger cooldown. The one-hit
beacon can be destroyed safely from inside or outside. **Payload Bolt (18s CD):**
1.6s crossbow aim, locked for 0.6s, physical bolt (0.35 hit). A direct hit attaches
a visible payload for 0.5s, then it drops at that position with a 1.5s audible
fuse; a miss lands directly on fixed ground. The 2.5-block explosion is 0.65 hit,
combined budget 0.9. No terrain damage; walk clear or break the visible charge
with one hit. Dropping the attached payload is the deliberate solo-trial escape
adaptation. Reload recovery 3s.

**Escalation:** Windstep changes angle after a failed payload. Do not fire while
the beacon's slow would make leaving the explosion mathematically impossible.

**Voice:** Open: “A bolt can finish its flight before it finishes its work.”
Half: “You noticed the fuse. Keep a way out before it starts.”
Win: “You answered both warnings. That is how you outlive a trap.”
Loss: “The impact was the first warning. The fuse was the second.”

## trapper — Leave Yourself an Exit

**Equipment and lesson:** crossbow, wire spools. Traps constrain routes through
visible geometry; they do not root a player under unavoidable damage.

**Tanglewire (24s CD):** 1.8s placement draws two 5-block wire strips with an
obvious 3-block opening between them; wires last 7s. Crossing gives 1s of 25%
slow, once per 3s; each anchor takes one matched hit. **Kill Zone (22s CD):**
1.8s warning reveals three snare cells in a 5-block patch, activated in order
1.3s apart with a 1s preview for each. A cell gives a 0.5s movement stop and
then releases; the cast can catch the player only once. A clearly drawn route
between cells remains open. The trial boss fires one separately warned 0.65-hit
bolt only after the stopped player has had 1.5s of free movement. Recovery 3s.
Breaking an anchor removes its wire immediately, including slow eligibility.

**Escalation:** Windstep observes the opposite side, with a fresh full preview
before any replacement wire. One layout at a time; no permanent trap carpet.

**Voice:** Open: “Before the first trap closes, know where your exit will be.”
Half: “You found one route. I have drawn another.”
Win: “You kept an exit, and made one when you needed it.”
Loss: “The anchor was as much a target as I was.”

## demolitionist — Spend the Fuse

**Equipment and lesson:** crossbow, three visible powder canisters. Multiple
blasts are ordered and bounded; particle density never substitutes for warning.

**Blast Marker (22s CD):** 1.5s amber stamp on fixed ground at the challenger's
captured position, valid for 6s. It can trigger once. **Cluster Bolt (24s CD):**
1.8s braced shot (0.25 hit), fixed aim for 0.7s. On landing it places three
charges in a visible triangle, each 2-block blast radius, leaving a safe central
gap. Fuses ignite at 1.6s, 2.4s and 3.2s after impact; all are visible immediately.
Shared blast budget 1.0 hit, total cast cap 1.2. A charge on Blast Marker gets
a brighter fuse and +0.1 hit, within that same cap. Each can be disarmed by one
matched hit; no block destruction. Recovery 3.5s after the final fuse.

**Escalation:** Windstep rotates the next triangle before launch; all positions
remain fixed from impact. No explosive can follow a player across the arena.

**Voice:** Open: “Three fuses. They do not ask for the same answer at once.”
Half: “The pattern has turned. The order is still there to read.”
Win: “You gave each fuse exactly the attention it deserved.”
Loss: “The first blast was not a reason to run into the second.”
