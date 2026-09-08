# Paladin branch encounters

Companion to [the encounter contract](class-trial-encounters.md). These are
authored designs, not implemented fights. Timing and damage are starting values
for playtesting. `CD` starts after recovery; `hit` means a normalized ordinary
trial boss hit. All temporary actors and objects use the ownership, finite
budgets and readable hitboxes specified in the contract.

## guardian — The Space Between

**Equipment and lesson:** spear, shield, steel armor; intercept a threat without
making the protected ally impossible to reach. One apprentice attacks slowly
with a sword. A thin gold tether identifies who is protected.

**Intercession (16s CD):** 1.4s shield raise, then a 5s link transferring 60% of
the apprentice's incoming damage to the trial boss. The trial boss takes that
damage normally; this is an alternate way to hurt him, not free mitigation.
**Guardian Ring (20s CD):** 1.5s expanding shield outline, then a stationary
4-block ring for 6s. The apprentice has 40% reduction inside it. Lure him beyond
the border to expose both the link and the slow guardian. Intercession ends with
2s of lowered guard; the ring expires without an explosion.

**Escalation:** at 50%, a telegraphed Divine Steed interception moves the guardian
to his apprentice before the next link. Its 2.5s dismount recovery remains.
No extra apprentice respawns. Counterplay is positioning and target choice.

**Voice:** Open: “The space between a blade and an ally belongs to you.”
Half: “You found my charge. Can you draw us apart?”
Win: “You understood whom I was protecting, and why.”
Loss: “Watch the tether. It tells you where your effort goes.”

## aegis — A Shield Has Edges

**Equipment and lesson:** sword, broad shield; defend one bow apprentice by
interception, not invulnerability. The apprentice fires one slow arrow every 3s.

**Aegis Link (18s CD):** 1.4s joining runes, then a 6s tether. Attacks against the
archer transfer 70% damage to Aegis while the pair remain within 7 blocks.
Separating them for 1s breaks the link and exposes Aegis for 2.5s (+20% damage).
**Sanctuary Wall (22s CD):** a 1.6s rising rectangular warning places a 5-block-wide
spectral shield for 5s. It stops hostile projectiles but is passable on foot;
its side edges are visibly open. Crossing it does not damage or stun. The
trial boss must lower it to attack, leaving 1.5s between guard and sword thrust.

**Escalation:** mount to the archer, dismount, then build the wall perpendicular
to the old firing lane. No wall appears behind an untelegraphed shot. The wall
vanishes if its caster dies; its collision does not alter arena blocks.

**Voice:** Open: “You see a wall. Look for its edges.”
Half: “A shield that never moves protects very little.”
Win: “You made me choose what I could no longer cover.”
Loss: “Do not keep feeding arrows into a shield. Change the angle.”

## bulwark — The Unbroken Line

**Equipment and lesson:** mace, tower shield, heavy plate. No helpers. A strong
stationary guard must trade away coverage and mobility.

**Hold the Line (18s CD):** 1.6s planted stance fixes a 100-degree forward guard
for 5s, reducing frontal damage 70%; rear damage is unchanged. Every 1.6s a
clearly raised mace precedes one short frontal swing (0.65 hit). Turning is
limited, never snapping to the challenger. **Unyielding Ground (22s CD):** 1.5s
outlined 4-block circle, 6s control resistance while standing inside; it gives
no additional damage reduction. Walk around the line or draw the trial boss out
after his stance ends. Both end in a 2.5s heavy-shield lowering animation.

**Escalation:** a steed charge establishes a new line after its normal recovery.
The next Hold the Line has two separated swing windows, not a full-circle hit.

**Voice:** Open: “This line will hold. You need not cross it head-on.”
Half: “A new line. The same mistake will still cost you.”
Win: “You knew when strength was simply facing the wrong way.”
Loss: “My shield covered the front. The rest of me was still there.”

## shieldbearer — Two Promises

**Equipment and lesson:** sword, shield; two sword cadets, each 3 matched hits,
0.2-hit attacks every 3s. Protecting two allies stretches one defender.

**Manyfold Intercession (20s CD):** 1.5s two gold links, then 6s redirecting 50%
of damage from each cadet to the trial boss. Each link breaks beyond 7 blocks;
breaking either causes a 1s guard stumble, both a 3s exposure. A single attack
cannot recursively bounce damage through links. **Covering Wall (24s CD):** 1.5s
shield fan then 4s of 35% cadet protection and a visible retreat corridor. The
cadets move; they do not attack during the retreat. Follow outside the shield
fan or meet them at its marked destination. Recovery 2s.

**Escalation:** the trial boss rides to the farther surviving cadet before
linking. No replacements for defeated cadets; without them, the trial boss
retains swordplay and steed but loses these defenses.

**Voice:** Open: “Two promises. One shield. See what that demands.”
Half: “You are making me work for both of them.”
Win: “You found the limit without mistaking it for weakness.”
Loss: “Separate our footing before you test our guard.”

## justicar — The Weight of a Blow

**Equipment and lesson:** mace and shield. Retaliation is visible, bounded, and
avoidable; damage is never invisibly reflected back to the attacker.

**Judgment (18s CD):** a 1.5s raised scale sigil precedes a 3s collection stance.
Up to three received hits light three orbiting weights; all still hurt the boss.
He then commits a 1.5s, 80-degree mace arc: 0.6 hit plus 0.2 per weight, capped
at 1.2. Sidestepping it grants 3s recovery. Stop feeding the stance, or deliberately
fill it and dodge for an opening. **Censure (16s CD):** a visible 1.3s bell ring
in a 4-block radius reduces outgoing challenger damage 15% for 3s; no slow or
forced facing. It cannot occur during the Judgment release.

**Escalation:** steed repositions before collection, never during the committed
arc. The cap and warning remain unchanged.

**Voice:** Open: “Every blow has weight. Watch where yours comes to rest.”
Half: “You know the price. Now choose when to pay it.”
Win: “Force, tempered by judgment. That will serve you.”
Loss: “You filled the scales, then stood beneath them.”

## templar — Mercy in the Reckoning

**Equipment and lesson:** ceremonial mace and shield; one sword novice. Turn
retaliation into support, but earn the recovery instead of receiving free heals.

**Consecrated Judgment (20s CD):** the Justicar collection and committed arc,
with a lower 0.9-hit cap. Only a landed arc heals the novice for one matched hit,
at most three times in the entire fight; it never heals the trial boss.
Missing leaves both unprotected for 3s. **Purging Bell (22s CD):** three spaced
chimes over 1.8s, then a 5-block cleanse and 4s debuff protection for the pair.
Two matched hits during the channel silence the bell and cause 2s recovery.
It grants no invulnerability and does not repeatedly remove every effect.

**Escalation:** steed rescue of the novice, then a choice of bell or collection
depending on whether the novice is hurt. The novice does not respawn.

**Voice:** Open: “A reckoning should leave someone better able to stand.”
Half: “Watch my companion. The next blow is meant for more than you.”
Win: “You denied the strike without losing sight of its purpose.”
Loss: “The bell can be stopped. You need not wait for it to finish.”

## inquisitor — No Rushed Verdict

**Equipment and lesson:** sword, offhand seal. Telegraph the execute window;
never use an actual instant kill against a learning player.

**Expose Heresy (18s CD):** a 1.2s seal traces the challenger, then marks for 6s
(+15% trial boss damage). The mark clears when a Final Sentence misses.
**Final Sentence (16s CD):** 1.8s sword held vertical, then a straight 7-block
thrust, direction fixed for the final 0.7s. Damage is 0.9 hit, rising to at most
1.2 below 35% challenger health. Passing to either side avoids it. The sword
sticks in a light seal for a 3s recovery; no follow-up basic attack.

**Escalation:** steed establishes a fresh approach, then mark and thrust, with
the complete dismount and thrust tells. Expose cannot refresh itself indefinitely.

**Voice:** Open: “A verdict is only as sound as the opening that supports it.”
Half: “Now I will test whether haste makes you predictable.”
Win: “You gave me no clean sentence. Well contested.”
Loss: “The seal warned you. The blade still had to reach you.”

## warlord — The Voice That Moves the Line

**Equipment and lesson:** sword and command pennant; two cadets as above.
The trial boss is noticeably less dangerous when separated from his followers.

**Commanding Shout (18s CD):** 1.4s horn and expanding 5-block outline; nearby
cadets gain 20% damage for 5s. Their next thrusts each get 1.2s independent tells
and are staggered by 1.5s. **Rally (20s CD):** 1.2s pennant rise clears their
slows once and guides them along two visible lanes for 3s. They do not strike
while moving. Break formation by crossing a lane or draw one out before the
shout. The trial boss has a 2s unguarded recovery after either order.

**Escalation:** ride to the far side and call one returning formation. No new
cadets and no damage to reward unavoidable surrounding.

**Voice:** Open: “A command is measured in the feet it moves.”
Half: “You broke our line. Let us see how quickly it reforms.”
Win: “You heard the order and found the answer.”
Loss: “Do not fight three blades where one voice makes them strongest.”

## marshal — Where the Standard Stands

**Equipment and lesson:** spear, planted standard, one spear cadet. Fixed rally
ground creates an advantage which can be destroyed or abandoned.

**Battle Standard (24s CD):** 1.8s banner planting, 8s lifetime, 5-block aura
giving the pair 20% damage. The banner takes two matched hits and grants a 3s
trial boss stagger when broken. It has a visible base hitbox; no tiny cosmetic
target. **Reform Ranks (18s CD):** 1.3s horn, 3s movement to either side of the
banner with 30% protection. Both recovery positions are marked before movement;
the challenger can intercept. No attacks until 1.5s after arrival.

**Escalation:** one steed reposition plants the next banner elsewhere after the
previous expires. At most one banner exists. Luring both outside its aura is
as valid as breaking it; the challenger is never forcibly aimed at the banner.

**Voice:** Open: “This cloth means nothing until we choose to stand by it.”
Half: “New ground. Read the formation again.”
Win: “You took away our ground before it could take away yours.”
Loss: “The banner had a reach, and a breakable base.”

## bannerlord — Keep Pace

**Equipment and lesson:** spear and a visible back-mounted standard; two cadets.
The mobile aura contrasts deliberately with Marshal's fixed banner.

**Grand Standard (22s CD):** 1.5s unfurl, then an 8s, 4-block aura carried by
the trial boss, granting cadets 20% damage. **Advance (18s CD):** 1.4s lane
warning then a 4s marching line. Cadets lose the aura if they pursue beyond its
edge; their attacks keep ordinary tells. Outflank the slow standard carrier or
draw the front cadet away. The banner folds into a 3s exposed rest after its
duration. Advance cannot extend the standard or overlap the rest.

**Escalation:** one short steed march, along a fixed lane; cadets stay on foot.
Going across the lane separates them more effectively than running ahead of it.
No helper respawns and no passive aura outside its authored duration.

**Voice:** Open: “A standard can move. Its people still have to keep up.”
Half: “Stay with me, cadets. Challenger, make that difficult.”
Win: “You found the distance a promise could not cover.”
Loss: “You retreated with our march. Try crossing it.”

## strategist — Break the Triangle

**Equipment and lesson:** sword, map case; a bow and a shield cadet. Three
visible connecting lines show whether formation bonuses are active.

**Perfect Formation (22s CD):** 1.8s assigned positions, then 6s of +15% damage
and 30% protection while all three remain within 5 blocks of one another.
The bow shoots first, shield advances 1.5s later; never simultaneous walls of
damage. **Fallback (20s CD):** 1.4s dashed retreat paths, then a 3s shielded
withdrawal with no attacks. Intercept the marked destination or draw one cadet
out: breaking the triangle removes all bonuses and exposes the trial boss 3s.

**Escalation:** reverse which cadet advances, visibly switching the order.
Steed is used only to reach the new command position after Fallback. A dead
cadet permanently breaks the triangle; basic sword pressure remains.

**Voice:** Open: “Three positions. One advantage. Find the dependency.”
Half: “You read the first formation. I have changed the order.”
Win: “You attacked the arrangement, not just the armor.”
Loss: “One corner out of place would have changed that exchange.”

## conqueror — Give Ground Deliberately

**Equipment and lesson:** sword and axe. Pressure should constrain decisions
without forcing an unavoidable pull-into-finisher combination.

**Dominating Roar (18s CD):** 1.5s inward-moving 5-block rings, then a modest
horizontal pull and 2s of 15% weakness; no damage. After contact, the trial boss
waits 1.5s before preparing another attack. **Press Forward (16s CD):** 1.2s axe
lift, then three deliberate forward cuts over 4s, 0.55 hit each, 1.1 total budget.
Each fixes facing before its swing. Sidestep behind or disengage; 2.5s exhausted
recovery with +20% damage received.

**Escalation:** steed crosses the arena, then Roar attempts to reclaim that
ground. Its pull cannot drag the challenger through terrain or outside the arena.
No airborne follow-up and no damage bonus large enough to punish one mistake twice.

**Voice:** Open: “Ground can be yielded. Initiative should not be.”
Half: “You have room. Show me that you know how to use it.”
Win: “You gave ground on your terms, and took it back.”
Loss: “After the roar, you still had a moment to choose your direction.”

## tyrant — Refuse the Easy Order

**Equipment and lesson:** heavy axe, severe black plate. Intimidating trial boss,
still teaching; no forced camera turns or loss of player controls.

**Kneel (20s CD):** 1.6s axe butt striking the ground, three outward ring fronts
0.6s apart. One contact causes a brief backward displacement and 2s weakness;
the whole cast has a single-contact budget, no damage. **No Escape (18s CD):**
1.5s four closing, visibly broken arcs leave a 3-block exit corridor. Crossing
an arc gives a 1s slow; the gap stays safe. The corridor direction is fixed at
warning start. Tyrant then makes a separately telegraphed 1.4s axe cut (0.8 hit),
after any slow has expired. Recovery 3s.

**Escalation:** steed takes the previous exit, then a new visibly announced
corridor is used. Neither attack restricts every direction or hides the exit.

**Voice:** Open: “I can command you to kneel. You can make it an empty order.”
Half: “Still standing. Good. Find your way out again.”
Win: “You did not mistake a loud command for an inevitable one.”
Loss: “You watched me. You should have watched the opening I left.”

## champion — The Honest Duel

**Equipment and lesson:** sword; axe appears for the final committed cut.
No plate-based bonus, helpers or healing. Read a sequence and punish its end.

**Duel Order (16s CD):** 1.3s sword salute, then a 70-degree front pulse with
light horizontal push and a visible duel mark for 5s; no damage or slow.
**Blade Dominion (18s CD):** 1.5s windup, left cut, right cut, overhead axe,
spaced 1s and 1.3s apart. The first two have 0.45-hit damage; the final 1.1,
with a 1.4 shared budget. All directions lock separately 0.5s before impact.
Dodge across the early arc or step behind the overhead. Final recovery 3s.

**Escalation:** Divine Steed sets an approach before the salute. The sequence
then begins with the opposite hand, advertised by its raised weapon. No random
unmarked reversal. Champion takes 20% extra damage during the final recovery.

**Voice:** Open: “No ranks behind me. No wall between us. Read the blade.”
Half: “You know the rhythm. Watch which hand begins it.”
Win: “A fair opening, well taken. You have earned this.”
Loss: “The last swing was the commitment. That was your opening.”
