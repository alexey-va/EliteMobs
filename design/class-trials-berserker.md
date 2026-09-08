# Berserker branch encounters

Designs governed by [the shared contract](class-trial-encounters.md), not runtime
content. Damage is expressed in normalized hits. Each leap has a fixed landing
marker and the root's recovery; it never automatically follows crowd control.
Blood effects use sparse red dust and impact sounds, not opaque screen effects.

## bloodrager — Heat Without Haste

**Equipment and lesson:** axe, exposed arms, a visible three-segment Fury halo.
Low health makes aggression stronger but also creates risk for its owner.

**Frenzy (18s CD):** 1.5s breathing and rising red motes, then three alternating
cuts across 4.5s. Above half health each is 0.45 hit; below, 0.6, with a 1.2 total
budget. The trial boss takes 20% extra damage during Frenzy. Cuts lock facing
0.5s before impact. Recovery 3s. **Blood Roar (20s CD):** a 1.4s roar clears slows
once and fills the halo; it causes no player interruption. Two matched hits
during its windup cancel the next Frenzy's damage increase, with an audible
lost-breath response.

**Escalation:** at half health, a fully warned Crater Leap precedes the next
Frenzy, separated by 2.2s landing fatigue. No acceleration of the warning times.

**Voice:** Open: “Feeling the heat is easy. Keeping your hands steady is the work.”
Half: “Less blood. More fire. More openings, too!”
Win: “You kept your head while I tried to take it off. That will do!”
Loss: “You matched my temper when you needed to read my shoulders.”

## reaver — Hunger Has a Reach

**Equipment and lesson:** hooked axe and scarred armor. Lifesteal only rewards
a connected attack; there is no periodic free heal.

**Scent Blood (18s CD):** 1.3s sniff and tracing motes mark the challenger for
5s and increase pursuit speed 15%. A missed Feast clears the mark immediately.
**Blood Feast (16s CD):** 1.6s hooked-axe windup, then a forward hook and returning
sweep 1.2s apart. Each deals 0.55 hit, with a 0.9 combined cap. The trial boss
heals 2% maximum health only on the first connected swing, at most six times
per run. Stepping across the hook's committed side avoids both; recovery 2.8s.

**Escalation:** Crater Leap closes distance before Scent, never onto a recently
hooked player. The healing budget remains 12%, with spent red beads going dark.

**Voice:** Open: “Hunger is useful. Reaching too far to feed it is not.”
Half: “I can smell an opening. Let us see whether it is real.”
Win: “You let the teeth close on empty air. Nicely done.”
Loss: “Every bite you gave me bought another exchange.”

## bloodstorm — Leave the Red Ground

**Equipment and lesson:** scythe, axe at the belt. A moving spin and a fixed
healing pool ask different positioning questions.

**Gore Trail (22s CD):** 1.5s dragging the scythe marks a 6-block trail, at most
2 blocks wide, lasting 6s. While inside it, the trial boss can heal 1% per
second, capped at 10% across the fight. It never damages players on its own.
**Crimson Cyclone (18s CD):** 1.8s outward spiral, then a 3s advancing spin in
a committed direction, 3-block radius. Three damage pulses have a shared
1.1-hit cap; connected pulses share a separate 2% fight healing budget.
Run across the path or pull the spin away from its trail. Recovery 3s, +20%
damage received; no instant reorientation toward the player.

**Escalation:** leap to create a new trail only after the previous one expires.
The landing marker and trail preview appear before movement.

**Voice:** Open: “The storm feeds where it stands. Choose where we fight.”
Half: “You took my ground. I will have to earn new ground.”
Win: “You moved the fight, and the storm ran dry.”
Loss: “You kept me standing in the very thing that sustained me.”

## deathless — One More Breath

**Equipment and lesson:** axe, battered plate, one bright chest rune. Survival
is a finite resource, visibly spent, not an endless second phase.

**Defiant Roar (24s CD):** 2s audible inhale, then 4s of 40% protection and a
2% heal, available only twice per run. Two matched hits interrupt the inhale.
No attacks during the protected first second. **Refuse Death (once per run):**
the first otherwise fatal hit breaks the chest rune, leaves the trial boss at
1 health, and restores 8% maximum health over a protected 2s kneeling sequence.
The challenger receives no damage during it. Protection ends with a clear
exhale and 2s recovery before the trial boss attacks again. The rune stays dark.

**Escalation:** half health adds a Crater Leap with normal warning. The one-time
survival is the final dramatic beat, not a reset of helpers, CDs or healing budget.

**Voice:** Open: “Count the breath you still have. Spend it well.”
Half: “Not finished. Neither are you.”
Win: “That last exchange was earned. I have no breath left to dispute it.”
Loss: “Surviving the blow is useful only if you use the moment after.”
Rune break: “One breath left. Watch what I do with it.”

## slayer — Do Not Offer the Finish

**Equipment and lesson:** sword and axe. Low player health increases threat
within a strict cap; a wounded challenger still gets a full dodge window.

**Executioner's Rhythm (17s CD):** 1.4s weapon beat followed by two cross-cuts
and a thrust over 3.5s. Normal 0.4/0.4/0.65 hit; below 35% challenger health
only the thrust becomes 0.9. The entire sequence caps at 1.2. Each direction
locks 0.5s before release; recovery 3s. **Relentless Hunt (20s CD):** 1.2s eye
glint and 5s of +15% pursuit speed, but no attack-rate increase. A missed final
thrust ends the hunt and makes the trial boss stop rather than immediately chase.

**Escalation:** leap establishes pursuit before the next rhythm. Never shorten
warnings when player health is low, and never preserve the mark after the run.

**Voice:** Open: “A wounded foe is dangerous. Haste makes that easy to forget.”
Half: “The finish is tempting. Show me you will not offer it.”
Win: “You denied the last stroke and took your own.”
Loss: “Being hurt did not remove the opening. Panic hid it.”

## headsman — The Blade Must Fall Somewhere

**Equipment and lesson:** large two-handed axe. One dramatic execute instead of
constant rapid pressure; stationary commitment is its weakness.

**Condemn (20s CD):** 1.4s axe pointing and a clear downward chevron over the
challenger for 6s. **Final Stroke (18s CD):** 2s raised axe, a 2-block-wide,
6-block-long warning strip fixes for the final 0.8s, then one 1.1-hit impact
(1.4 maximum against a wounded, marked target). A miss breaks Condemn.
Recovery 3.5s with the axe embedded and +25% damage received. No invisible
oversized melee box around the trial boss.

**Escalation:** a Crater Leap gives a new angle; complete landing recovery
precedes the axe raise. No second fake-out stroke or cancel into a tracking hit.
The heavy hit is never allowed while a prior displacement still prevents escape.

**Voice:** Open: “A great blade cannot fall everywhere. Remember that.”
Half: “You know where it will land. Trust your feet.”
Win: “You made the weight of my axe your advantage.”
Loss: “You retreated along the blade. Step across its path.”

## harvester — Break the Chain

**Equipment and lesson:** scythe. Two clearly labeled, already-wounded training
effigies make the chain mechanic visible without inventing multiple players.

**Harvest Chain (22s CD):** 1.8s connected paths show an ordered dash through
the effigies and then the challenger's captured position. Each leg has 0.6s
travel plus a 0.5s pause. Only the final leg can hurt the challenger (0.9 hit).
Breaking an effigy first removes that leg and causes a 2s recovery at the missing
link; a completed chain ends in 3s recovery. Consumed effigies heal the trial boss 2% each, with three pairs maximum
(12% total). **Reap the Weak (18s CD):** 1.5s scythe hook line, modest horizontal
pull within 6 blocks. No damage; Harvest cannot start until 1.5s after it resolves.

**Escalation:** leap places the final pair farther apart, within reachable
arena ground. Each effigy takes one matched hit; the player can deny all healing.

**Voice:** Open: “A harvest follows a line. Remove what the line depends on.”
Half: “Two more links. I suspect you know what to do with them.”
Win: “You broke the chain before it reached you.”
Loss: “The next destination was drawn before I moved.”

## juggernaut — Weight and Distance

**Equipment and lesson:** mace and heavy armor. Deliberate radial pressure;
control resistance does not mean damage immunity.

**Earthshatter (18s CD):** 1.8s mace lift marks a 3.5-block circle; one 0.9-hit
impact with a modest launch. A hit grants 1.5s protection from subsequent
scripted damage; recovery 2.8s. **Unstoppable (22s CD):** 1.3s armor-lock sound,
then 5s of control resistance with normal damage taken and 15% slower turning.
The trial boss visibly walks rather than suddenly dashes. Step outside the
Earthshatter circle, then use recovery to close again.

**Escalation:** Crater Leap introduces a distant landing circle, then the
trial boss must recover before Earthshatter. No overlap of landing and mace
damage and no launch-to-launch trap.

**Voice:** Open: “You will not move me easily. You can still move yourself.”
Half: “The weight is coming to you. Read the landing.”
Win: “You made every heavy step cost me time.”
Loss: “Do not spend the whole warning trying to push me away.”

## crusher — Read the Fault

**Equipment and lesson:** mace with a broad stone head. A radial quake and a
linear fault use different shapes and independent, limited hit budgets.

**Fault Line (16s CD):** a 1.5s crack traces a fixed 10-by-2-block strip, then
three forward impact sections 0.4s apart. Only one section may hit the player
(0.65 hit, light launch). **Sunderquake (20s CD):** 1.8s concentric preparation,
then a 4-block ground slam (1 hit). The player can sidestep the strip or leave
the circle; each attack has 2.8s recovery. A launched player receives the shared
1.5s grace period before any other scripted hit.

**Escalation:** Fault Line first, recovery, then a leap whose landing circle is
offset from the old crack. The arena never changes blocks or leaves hidden
collision behind after the visual crack fades.

**Voice:** Open: “Stone tells you where it will break. Watch the crack.”
Half: “The next fault runs a different way.”
Win: “You read the ground before it moved.”
Loss: “The line was narrow. Running along it kept you in reach.”

## siegebreaker — An Opening, Not a Wall

**Equipment and lesson:** mace, axe used for Breach. Explicit armor pressure,
with a safe opportunity to wait out the vulnerability.

**Breach (18s CD):** 1.4s axe draw, committed 70-degree short sweep (0.55 hit).
Contact applies 15% increased damage received for 4s, clearly shown by a cracked
shield icon. **Ruinous Impact (22s CD):** 1.8s mace raise marks a 4-block circle,
then a 1.1-hit slam and 3s recovery. It may follow Breach only after 1.5s of free
movement. Leaving its circle avoids the payoff; its full damage remains capped
at 1.3 after Breach. Breach does not disable food, player movement or healing.

**Escalation:** leap establishes a new breach attempt; no refreshing the debuff
through repeated contact hits. The trial boss takes +20% damage during the
slam's recovery, providing an offensive answer to the defensive lesson.

**Voice:** Open: “Breaking a guard is only the beginning. The opening can close.”
Half: “Your shield is not your only way to survive this.”
Win: “You let the breach expire and answered the commitment.”
Loss: “Once exposed, buy space before trading another blow.”

## titanbane — Stop the Charge

**Equipment and lesson:** spear and mace. One large training construct makes
the anti-large identity legible; it is not a second full boss.

**Anchor Chain (22s CD):** the construct begins a 2s warned, 2-block-wide charge.
The trial boss plants a visible chain stake and halts it; the chain stretches
across the arena for 4s. The challenger can break the stake (two matched hits)
to interrupt the trial boss's next attack. No chain roots the challenger.
**Giant Killer (20s CD):** 1.8s spear alignment at the anchored construct, then
a committed thrust along the visibly extended chain line (0.9 hit if crossed).
On success the construct kneels; on a broken chain the trial boss overextends.
Both outcomes give 3s trial boss recovery, with +25% damage on interruption.

**Escalation:** leap takes the opposite side before the next demonstration.
Construct charge can hit only once (0.45 hit), and never overlaps Giant Killer.
If destroyed directly, it stays gone and the trial boss uses warned spear thrusts.

**Voice:** Open: “A larger enemy commits more weight. Give that weight a limit.”
Half: “Now watch the anchor as closely as the giant.”
Win: “You found what held the exchange together, and broke it.”
Loss: “The chain marked the thrust. It also gave you something to break.”

## dreadnought — Between the Rings

**Equipment and lesson:** mace, reinforced plate. Traveling impacts reward
crossing an expired ring, not running forever from an expanding attack.

**Seismic Chain (22s CD):** 1.8s preparation, then three discrete rings at
radii 2, 4 and 6 blocks, 0.8s apart. Each ring is 1 block thick and individually
warned before activation. Move into the already-spent inner ground. One cast
caps damage at 1.1 hits; no simultaneous full disc beneath all rings.
**Iron Roar (20s CD):** 1.4s armor resonance, 5s control resistance, no damage
reduction. The trial boss remains still during the chain and rests 3s afterward.

**Escalation:** leap shifts the center for the next chain. It still starts only
after landing recovery, and the new center is visible before its first ring.

**Voice:** Open: “The first impact is not the last. Nor does it stay dangerous.”
Half: “New center. Same rhythm.”
Win: “You stepped into ground the quake had already spent.”
Loss: “You kept fleeing toward the next ring. Look behind the one that passed.”

## warmonger — Noise Is Not Direction

**Equipment and lesson:** axe, heavy shoulders. Disruption should be threatening
without taking away the challenger's camera or control for long periods.

**Challenge All (18s CD):** 1.5s four horn sectors, leaving one broad quiet
sector; contact causes 1s weakness, no forced facing. **Panic Engine (22s CD):**
1.6s axe drumming followed by two 90-degree sweeps separated by 1.3s, each
0.65 hit, shared cap 1.1. The first gives a small horizontal shove; 1.5s grace
prevents the second from punishing an immobilized player. Recovery 3s.
The quiet sector is a route to the trial boss's back, not a stationary safe
point under an incoming unmarked attack.

**Escalation:** leap changes the orientation of the sectors. Their warning
always shows the new orientation for the full duration; no overlapping fear.

**Voice:** Open: “A battlefield is loud. Noise does not get to choose your feet.”
Half: “More noise. The opening is still there.”
Win: “You heard everything and obeyed only what mattered.”
Loss: “Watch the shoulders through the shouting.”

## colossus — The Cost of Commitment

**Equipment and lesson:** enormous mace, heavy armor. The longest, heaviest
commitment in the tree comes with its largest punish window.

**Immovable (24s CD):** 1.5s planted feet and shield outline grant 40% protection
and control resistance for the next charge only. **Worldbreaker (24s CD):** a
2.5s charge brightens three ground cracks into a 6-block-radius warning with a
clearly open 80-degree rear wedge. The facing fixes after the first second.
The impact deals at most 1.4 hits; the rear wedge is truly excluded from damage.
Three matched hits during the charge break Immovable, cancelling the strike
into a 4s kneeling recovery. Otherwise the landed or missed strike also ends in
4s recovery, with +25% damage received. No passive heals.

**Escalation:** leap establishes a new position before the charge. It does not
remove the rear wedge, speed the heavy tell, or refresh the charge's shield.

**Voice:** Open: “All this weight goes somewhere. Find where it does not.”
Half: “I am committing everything. You should not.”
Win: “You understood the price of that swing, and collected it.”
Loss: “When the ground began to split, my direction was already chosen.”
