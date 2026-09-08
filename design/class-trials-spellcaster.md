# Spellcaster branch encounters

Authored designs under [the shared contract](class-trial-encounters.md). They
have not been implemented or played. Wands/staffs below mean the canonical
EliteMobs/FMM weapon representation; a decorative stick plus contact melee is
not sufficient. Magic projectiles collide with terrain and entities. Curved
paths use segment collision and cannot steer through walls. No ambient spell
may keep damaging after its run is closed.

## mage — Read the Second Cast

**Equipment and lesson:** wand, book in offhand. A repeated spell has its own
preparation and direction; an echo is not an invisible damage multiplier.

**Arcane Volley (14s CD):** 1.5s three lights gather at the wand, then three
straight bolts 0.6s apart. Each direction commits 0.4s before release, 0.35 hit,
shared 0.9 cap. Recovery 2.5s. **Spell Echo (22s CD):** 1.4s mirrored rune arms
the next volley within 6s. A visible afterimage holds its firing location and
repeats only the final bolt after a separate 1.2s warning, 0.45 hit, with a
1.1 total cap including the original volley. Strike the one-hit echo rune or
move out of its fixed line to deny it.

**Escalation:** Blink changes the caster's position before the volley; the echo
stays where that volley was released. No duplicate homing and no contact attacks.

**Voice:** Open: “A spell may finish once and still have something left to say.”
Half: “I have moved. Notice which part of the spell has not.”
Win: “You accounted for the second cast before it surprised you.”
Loss: “The afterimage was still drawing when you stopped moving.”

## elementalist — Three Different Answers

**Equipment and lesson:** staff with three orbiting runes. Fire, frost and
lightning ask different positioning questions; they cannot hit simultaneously.

**Elemental Exposure (24s CD):** 1.6s reveal of three runes in the exact upcoming
order, granting at most 10% damage increase on one subsequent hit. **Elemental
Convergence (26s CD):** three stages, each 1.4s warning and 0.8s safe interval:
fire makes a fixed 3-block circle to leave; frost a narrow moving front to
cross; lightning a committed 2-block line to sidestep. Each is 0.45 hit, total
1.1 cap. Frost gives only 0.5s of 15% slow, expiring before lightning's warning.
Recovery 3.5s after all three. Shape identifies the element without relying on color.

**Escalation:** Blink establishes the next origin and rotates the rune order,
fully previewed. No random substitution after the order has been shown.

**Voice:** Open: “Three elements. Three questions. One answer will not suit them all.”
Half: “A different order. Read the runes before the first release.”
Win: “You changed your answer when the question changed.”
Loss: “The runes gave you the order; the shapes gave you the response.”

## pyromancer — Leave the Kindling

**Equipment and lesson:** staff, ember robes and the selected Flame Lord skin.
Persistent fire grows from a fixed, announced source with a reachable off switch.

**Flashover (22s CD):** 1.5s three sparks mark the challenger's captured ground,
then a visible, two-hit ember brazier appears there for 7s. **Inferno (24s CD):**
1.8s rising flame outline around that brazier, a 4-block circle active for 4s.
Four pulses deal 0.3 hit each, shared 1.0 cap; no extra vanilla fire-tick damage
on top. Destroying the brazier ends all pulses and exposes the caster 3s.
Leaving its circle is equally valid. A clear inner ember and low perimeter
flames keep the ground readable; no opaque particle cylinder.

**Escalation:** Blink puts the caster across the existing fire before recovery,
but cannot place a second Inferno until the first expires. No terrain ignition.

**Voice:** Open: “Fire is very persuasive. You are still allowed to leave.”
Half: “You have learned to leave the heat. Now consider its source.”
Win: “A fine answer. No wasted steps, and very little singeing.”
Loss: “The brazier fed the flame. It was not merely decoration.”

## cryomancer — Where the Snow Thins

**Equipment and lesson:** staff, frost mantle. A bounded storm with a visible
safe sector; no white screen, hard freeze, or unavoidable follow-up.

**Whiteout (24s CD):** 1.8s snowflake spokes preview a 5-block annulus with an
open 90-degree sector. It lasts 5s, with light sparse flakes and 0.25-hit pulses
at 1s intervals, capped at 0.8. Contact slows 20% for 0.8s; safe ground clears
the encounter's own slow. **Ice Barrier (22s CD):** 1.6s three rising shards,
two-hit shield for at most 5s; breaking it causes a 3s shatter recovery, expiry
2s. It cleanses once and never heals. Attack the barrier from the clear sector
or wait beyond the storm; the trial boss cannot attack during shatter recovery.

**Escalation:** Blink moves before the next storm, which must show its new
sector for the full warning. Barrier cannot refresh itself while still intact.

**Voice:** Open: “Snow conceals less than people think. Look where it thins.”
Half: “A new wind. Find the clear side before it settles.”
Win: “Patient, and observant. The cold had very little to work with.”
Loss: “The clear sector was a path to the barrier, not just a place to wait.”

## battlemage — The Rune Behind the Blade

**Equipment and lesson:** wand, with a temporary blade of light projected during
Cleave. This remains a magic attack from the class's actual wand affinity, not
a new physical-sword proficiency. Short sweep range joins a bounded ward.

**Arcane Cleave (16s CD):** 1.5s sword traced with runes, then an 80-degree,
4-block sweep (0.85 hit). Direction fixes for the final 0.6s. A connected hit
grants one-hit shield for 3s; a miss grants none. Recovery 2.8s. **Runic Guard
(20s CD):** 1.4s three runes, 40% reduction on at most two incoming hits over
4s. Breaking both runes exposes the caster for 2.5s. The guard is not a heal
and does not stack with the cleave's shield; only the stronger defense applies.

**Escalation:** Blink approaches a visible flank before the next cleave, with
1.3s arrival recovery and a fresh full sword windup. No teleport-hit in one tick.

**Voice:** Open: “The rune supports the blade. It does not lengthen my arm.”
Half: “Another angle. The sword still has to finish its swing.”
Win: “You separated the spell's promise from the blade's reach.”
Loss: “You could have crossed behind the committed sweep.”

## spellblade — The Gap Between Cuts

**Equipment and lesson:** wand, a conjured aether blade visible only during the
signature, light armor. The cuts are magic, not physical-sword attacks. Fast
fencing gets clear beats and a real ending; magic must not erase every melee weakness.

**Warcasting (22s CD):** 1.4s runic step activates 5s of +15% movement, +10%
spell damage and a one-hit shield. **Aether Blade (18s CD):** 1.5s raised blade,
then three narrow thrusts 0.8s apart. Each fixes facing for 0.45s, deals 0.4 hit,
combined cap 1.0 including Warcasting. The final thrust visibly overextends for
3s of recovery with +20% damage received. Lateral
movement beats retreat straight down the lane. Warcasting expires at the end
of the sequence and cannot conceal that exposure behind another shield.

**Escalation:** Blink moves to the opposite side before the next preparation.
No mid-sequence teleport, animation-cancelled thrust or attack during arrival.

**Voice:** Open: “Quick hands still need a rhythm. Listen for the gap.”
Half: “Keep the rhythm. I am changing only where it begins.”
Win: “You let the last thrust pass and answered the space it left.”
Loss: “Retreating down the line kept all three thrusts in play.”

## arcane_knight — Break the Cast, Keep the Guard

**Equipment and lesson:** wand and shield, a conjured rune blade for Spellbreaker. One sword
cadet makes group shielding meaningful without a summoning theme.

**Spellbreaker (18s CD):** 1.5s blade hum and a fixed 7-by-2-block thrust,
0.8 hit and 2s of 15% weakness. It does not disable every player ability.
Recovery 2.8s. **Aegis Pulse (22s CD):** 1.8s outward rune pulse, one-hit shields
for the pair within 5 blocks, lasting 5s. Two matched hits during preparation
interrupt the pulse, otherwise separating the cadet before release denies their
shield. The trial boss receives no additional armor multiplier on top.

**Escalation:** Blink returns to the cadet before preparing Aegis Pulse, with
a full destination tell and landing pause. The cadet does not respawn; without
them, the trial boss still has a bounded personal shield.

**Voice:** Open: “A guard can answer a spell. It must still be raised in time.”
Half: “Watch the return to my companion. That is where the pulse begins.”
Win: “You found the cast before the guard could answer it.”
Loss: “The pulse needed time and nearby company. You could deny either.”

## occultist — What the Shadow Outlines

**Equipment and lesson:** staff and dark folio. A long piercing lance with a
revealed path, not blindness or invisible attacks.

**Occult Sight (22s CD):** 1.5s open-eye sigil marks the challenger for 6s and
reveals the next lance's line early. Damage increases only 10%, within the
lance cap. **Umbral Lance (18s CD):** 1.8s shadow drawn inward to the staff,
then one terrain-blocked, entity-piercing bolt along a 1.5-block-wide fixed
lane, 0.9 hit. Direction locks for the final 0.7s. Contact weakens outgoing
damage 15% for 2s; a miss breaks Sight and exposes the caster for 3s.
No player camera darkening; the edge of the lane uses bright violet motes.

**Escalation:** Blink changes the launch position, then Sight redraws the whole
lane. No beam that keeps following after its visible commitment.

**Voice:** Open: “Darkness is useful because people stop looking carefully.”
Half: “You are still looking. Let us change what you are looking at.”
Win: “You saw the outline and ignored the theatrics. Sensible.”
Loss: “The dark center was not the important part. Its edges were.”

## necromancer — Deny the Body

**Equipment and lesson:** staff, bone folio, selected Dreygyr skin. Soul Drain
uses prepared elite corpses to raise servants, matching the actual unlock theme.

**Soul Drain (24s CD):** one of three named, inert training remains receives a
2.3s thread from the staff. Its two-hit bone focus can be shattered during the
channel, causing 3s caster recoil. Otherwise one undead servant rises for 10s,
four matched hits, slow 0.3-hit swings; its successful attacks can heal the caster
1% each, capped at 6% for the whole fight. **Grave Chill (20s CD):** 1.5s cold
outline at a fixed 3-block circle, lasting 4s, 20% slow and 15% weakness inside,
no damage. Leave it or destroy the one-hit grave candle to end it.

**Escalation:** Blink retreats toward another unused body, advertising the next
raise. Maximum two servants alive, three raises total, no live elite hunting
outside the run and no generic skeleton summons without a corpse channel.

**Voice:** Open: “I brought my own dead. You may try to keep them unemployed.”
Half: “You noticed the bodies. There may be a useful mind in there yet.”
Win: “The dead were less useful than you were. An irritatingly good result.”
Loss: “You watched the corpse stand up. Next time, interrupt the invitation.”

## lich — An Anchor Can Be Broken

**Equipment and lesson:** staff, bone crown, one visible phylactery plus two
prepared corpses. Death prevention has a discoverable, destructible source.

**Death Coil (24s CD):** 2.2s coil into one corpse raises a draining servant
for 10s, four matched hits. Its slow 0.3-hit attacks heal 1% on contact, up to
4% across the fight. **Phylactery Ward (once):** 2s assembly of a three-hit urn
gives the trial boss one fatal-hit prevention while the urn survives. A gold
bone thread always points to it. Destroying it ends the ward and opens 3.5s
exposure. If spent by a fatal hit instead, the urn shatters, restores 6% health,
and grants 2s kneeling protection followed by 2s safe recovery. It never respawns.

**Escalation:** Blink returns toward the urn or remaining corpse; full warning.
No reset of servants, health budget or used protection when the ward triggers.

**Voice:** Open: “Immortality is an arrangement. Find the other party.”
Half: “Yes, the urn matters. I had hoped you would be less observant.”
Win: “You read the terms and terminated the agreement. Adequate.”
Loss: “The thread led to my insurance. You were free to cancel it.”
Ward spent: “One clause exhausted. Do not expect another.”

## plaguebringer — Stop the Carrier

**Equipment and lesson:** staff, stained robes, prepared corpse markers.
The rot zone belongs to a raised servant; killing or moving it controls the hazard.

**Rotting Ground (24s CD):** 2.3s raising channel at a two-hit corpse focus,
then one four-hit rot servant for 10s. After a separate 1.5s warning it trails
three 2-block patches, each lasting 3s, never more than three live patches.
Each patch can deal 0.25 hit once; the whole summon caps at 0.9 player damage
including its ordinary attack. **Miasma (22s CD):** 1.6s broken 4-block ring
around the servant, 4s of 15% slow and weakness, no extra damage. A wide gap is
previewed and stays open. Killing the servant ends every owned patch and cloud.

**Escalation:** Blink points toward the next corpse. Maximum three raises in
the fight, one servant at a time; no lasting arena contamination or vanilla poison.

**Voice:** Open: “A plague needs a carrier. I suggest you take an interest in mine.”
Half: “You have contained one outbreak. Here is another source.”
Win: “Containment before panic. Unexpectedly professional.”
Loss: “You kept fighting the stain while its carrier made more.”

## summoner — Who Gives the Order

**Equipment and lesson:** wand and command focus. A chosen animal companion
has a real role and tells, rather than two generic helpers per cast.

**Arcane Servitor (two charges, 26s CD):** 2s portal silhouette forms a wolf,
four matched hits, 12s life. It stalks and makes one 1.3s warned pounce every
4s, 0.4 hit. No instant attack on spawn. **Commanding Sigil (22s CD):** 1.6s
two-hit sigil appears between master and companion; for 6s it grants the wolf
a one-hit shield and +15% damage while within 5 blocks. Breaking the sigil
ends both benefits and opens 3s caster recovery. Separating the wolf also works.

**Escalation:** Blink shifts to the far side of the sigil before the next
command. Only one servitor exists; a second charge requires the first to end.
The caster keeps slow 0.35-hit wand bolts, suspended during pounce warnings.

**Voice:** Open: “A summon is a companion with a task. Watch who gives the order.”
Half: “We will try another angle. The command still needs its focus.”
Win: “You understood the partnership, and interrupted it intelligently.”
Loss: “The sigil was helping the wolf more than another hurried swing helped you.”

## demonologist — Read the Price

**Equipment and lesson:** staff, pact seal, ember cloak. A dangerous summoned
ally comes with a visible cost in the trial boss's defense.

**Abyssal Gate (two charges, 28s CD):** 2.3s three ground seals open a portal.
Destroy its two-hit anchor to interrupt; otherwise a four-hit Nether servitor
arrives for 10s. It fires one 1.4s-warned, terrain-blocked ember every 3s,
0.4 hit, no fire-tick damage. **Pact of Ruin (24s CD):** 1.8s red thread binds
caster to servitor for 5s, granting the servitor +20% damage and a one-hit shield,
but the trial boss takes +25% damage for the same duration. The price is shown
by a broken shield over the caster. Killing the servitor ends the benefit,
but not the paid vulnerability. Recovery 3s after the pact.

**Escalation:** Blink moves away before the second gate; no third charge, no
invulnerability while channeling, and no minion attacks overlapping portal arrival.

**Voice:** Open: “Power has a price. You are welcome to collect mine.”
Half: “A larger promise. The same unpleasant terms.”
Win: “You read the cost before admiring the power. A useful habit.”
Loss: “The broken shield told you who was paying for that pact.”

## spiritbinder — Separate the Guardians

**Equipment and lesson:** wand, spirit lantern. One protective eidolon links
defense and positioning; it cannot phase through walls to hit the challenger.

**Guardian Eidolon (two charges, 26s CD):** 2s lantern opening summons a four-hit
Vex for 12s, constrained to navigable arena space. It makes a 1.4s warned
straight pass every 4s (0.35 hit), stopping at terrain. **Shared Essence (22s
CD):** 1.7s visible double thread; for 6s, 40% damage to either linked actor is
transferred once to the other, total damage conserved, plus one shared one-hit
shield. More than 1s beyond 6 blocks breaks the link, consumes the shield and
exposes the caster 3s. The lantern is a two-hit alternative target that dismisses
the current eidolon, giving the same opening.

**Escalation:** Blink deliberately stretches the next link before reconnecting;
the challenger can intercept that movement. No stacking eidolons or hidden
shield replacement, and no flying invulnerability to melee players.

**Voice:** Open: “Protection is a relationship. Watch the distance it can survive.”
Half: “We have moved apart. That is a choice you can use.”
Win: “You found the point where shared strength became a strained bond.”
Loss: “The lantern and the tether both gave you a way to separate us.”
