# Cleric branch encounters

> Historical design sketch. The current ordinary YAML/Lua implementation and
> ownership contract are documented in [class-trial-runtime.md](class-trial-runtime.md).
> Mechanics requiring private trial APIs were redesigned; this document is not
> an implementation contract or evidence that those APIs exist.

Designs under [the shared contract](class-trial-encounters.md), not implemented
content. These remain solo duels: attendants are encounter-owned sparring
partners on the trial boss's side. No unlocked healing ability is required to
win. They demonstrate why protection, triage, range and interruption matter.

Unless specified otherwise, attendants take three matched hits, make a warned
0.2-hit attack no more than once per 3s, and retreat permanently when defeated.
They give no drops or XP. At most three exist. Healing across trial boss and
attendants shares a **12% trial boss-max-health budget for the whole fight**;
it cannot revive a defeated actor. Interruptible channels show two descending
notes, are cancelled by two matched hits, and end in 2.5s recovery. These rules
prevent healer encounters becoming unbounded damage-per-second checks.

## priest — The Moment Before the Prayer

**Equipment and lesson:** mace, white robes, three lightly armed attendants.
The weakest recipient is visibly chosen before the prayer lands.

**Prayer of Mending (20s CD):** three pale threads identify the three weakest
living allies in order during a 2s channel. Completion sends a half-matched-hit
heal down each thread, weakest first, 0.4s apart; subsequent prayers choose again.
Damage the channel or finish a recipient first to deny its heal. **Purify
(18s CD):** 1.4s single-bell cue, cleanses
one attendant's negative effects once, grants 3s debuff protection. It gives no
health or damage reduction; recovery 1.8s.

**Escalation:** Guardian Flight moves to the most injured attendant's announced
position, with 1.5s landing recovery before a fresh prayer. Without attendants,
the trial boss can pray for herself using the same interruption and total budget.

**Voice:** Open: “Before a prayer is answered, someone must find the moment to speak.”
Half: “Watch who needs help. That is where my attention will go.”
Win: “You saw the need, the answer, and the moment between them.”
Loss: “The bright thread showed where the prayer was going. Try that first.”

## hierophant — A Voice for Many

**Equipment and lesson:** ceremonial mace, layered vestments, three attendants.
Grouped healing trades broad coverage for a long, readable commitment.

**Benediction (24s CD):** 2.3s ascending three-note chord outlines a 5-block
circle, then heals each attendant inside for one matched hit, within the shared
budget. It cannot reach those lured outside. Two matched hits interrupt the
channel and expose the trial boss for 3s. **Sacred Silence (20s CD):** 1.5s quiet
inward ring, one cleanse of nearby attendants and a 1s, 15% weakness to the
challenger inside 3 blocks. It does not disable controls, chat, movement or all
abilities. No damaging attack for 1.5s afterward; recovery 2s.

**Escalation:** Guardian Flight regathers the trial boss with the remaining
attendants before the next Benediction. It does not teleport attendants back
into healing range or undo the player's separation work.

**Voice:** Open: “A voice can reach many people. It still has a reach.”
Half: “You have drawn us apart. I must choose where to stand.”
Win: “You understood the gathering before you interrupted the prayer.”
Loss: “Those outside the circle could not receive the blessing.”

## saint — Hope Is Not Endless

**Equipment and lesson:** trident, simple bright robes, one vulnerable novice.
A powerful emergency rescue is finite and visibly committed.

**Hallowed Ground (24s CD):** 1.6s petal border, 4-block circle lasting 6s.
Inside, the novice recovers one-quarter matched hit each second; lure them out
or strike the two-hit prayer candle at its center. **Miracle (once, below 25%
novice health):** 2.5s kneeling channel with a rising white thread to the novice,
restoring up to three matched hits on completion. Interrupting the channel
spends it; it never prevents an otherwise fatal hit invisibly. Recovery 3s.
All healing consumes the common budget, including Miracle.

**Escalation:** Guardian Flight becomes the announced rescue approach at half
trial boss health; Miracle is not refreshed. With the novice gone, ground can
heal the trial boss at 1% per second, only from the remaining budget.

**Voice:** Open: “Hope is precious. We must make room for it to work.”
Half: “There is still someone to stand beside. Watch my approach.”
Win: “You respected the moment without being ruled by it. Well done.”
Loss: “The candle sustained the ground. You could have quieted it.”

## exorcist — Mercy Beyond the Strike

**Equipment and lesson:** mace and censer, one attendant. Offensive support
only earns healing through a landed, dodgeable attack.

**Smite and Succor (18s CD):** 1.6s raised mace traces a fixed 6-by-2-block strip;
one 0.8-hit strike heals the injured attendant by one matched hit only if it
connects. Sidestepping denies both outcomes and grants 3s recovery. **Banish
(20s CD):** 1.5s censer sweep previews an 80-degree cone, modest horizontal
knockback and 2s weakness, no damage. Smite cannot begin until 1.5s after the
displacement, allowing ordinary movement to answer it.

**Escalation:** Guardian Flight protects the attendant's position before a
Banish, preserving the separate warning. No hard stun, blindness, holy damage
tick carpet or healing on a missed swing.

**Voice:** Open: “This strike is meant to bring relief. You may deny it that purpose.”
Half: “Watch where I return after making space.”
Win: “You saw the help behind the harm, and answered both.”
Loss: “Stepping outside the stroke would also have stopped the healing.”

## oracle — See the Rescue Coming

**Equipment and lesson:** trident, eye-pattern stole, one sword attendant.
Announced future protection invites restraint or deliberate shield breaking.

**Foreseen Rescue (22s CD):** 1.8s eye rune selects the attendant, then a ward
absorbs two matched hits for at most 5s. A broken ward heals the attendant one
matched hit; an expired ward heals nothing. Either outcome leaves the trial boss
unguarded for 2.5s of recovery. Attack the trial boss while the ward expires, or break it
to force that opening at a known, bounded healing cost. **Foresight (20s CD):**
1.5s visible eye above the trial boss, reduces the next received hit 50% within
4s, then vanishes. It never dodges every attack during the window.

**Escalation:** Guardian Flight repositions before choosing the next ward
recipient. No instant shield refresh when the player switches targets.

**Voice:** Open: “Seeing danger coming does not make every answer the right one.”
Half: “You can see my preparation too. Choose what you want it to answer.”
Win: “You made the future less certain by choosing well in the present.”
Loss: “You did not have to break the ward before turning your attention to me.”

## fateweaver — One Thread Rewritten

**Equipment and lesson:** spear, woven gold stole, two attendants. A single
death-prevention charge is readable, finite, and transferable only by a channel.

**Rewrite Fate (once per run):** 2s weaving chooses one attendant and visibly
ties the sole gold knot to them. For 6s it prevents one fatal hit, consumes the
knot and heals one matched hit. Let it expire or defeat the other attendant;
the trial boss cannot silently move it. **Prophecy (22s CD):** 1.6s three-note
prediction, 5s ward reducing the next heavy hit (at least one matched hit) by
50%. Its recipient is announced before activation. Recovery 2.5s; two matched
hits during weaving interrupt the assignment. No damage reflection.

**Escalation:** Guardian Flight reaches the unprotected attendant before the
next Prophecy. The consumed knot stays broken; all healing uses the total budget.

**Voice:** Open: “One thread may be rewritten. That does not make the cloth unbreakable.”
Half: “The knot is only in one place. Follow the thread.”
Win: “You saw what could be changed, and what could not.”
Loss: “The golden knot held one promise. There were other choices beside it.”

## seraph — The Reach of Mercy

**Equipment and lesson:** spear, feather mantle, three attendants. Chain healing
depends on adjacency, so breaking the middle connection is a meaningful choice.

**Chain of Mercy (22s CD):** 2s sequential notes preview an ordered chain, each
jump limited to 5 blocks. It heals one matched hit per reached attendant, stopping
at the first missing or distant link. Two matched hits interrupt the channel.
**Ascension (24s CD):** 1.5s feather paths, then attendants receive one-hit shields
and move toward marked gathering points for 3s. They cannot attack while moving.
Intercept the middle attendant or lead them away before the chain. Recovery 3s.

**Escalation:** Guardian Flight moves to the other end of the chain, reversing
the audible and visible order. It does not extend jump range or revive missing
links. The trial boss remains vulnerable while attendants move.

**Voice:** Open: “Mercy travels from one person to the next. Watch what joins them.”
Half: “I will begin from the other side. Follow the notes.”
Win: “You understood the distance between each act of care.”
Loss: “The middle thread was holding the whole chain together.”

## shaman — Beyond the Tether

**Equipment and lesson:** trident, carved spirit focus, one attendant. A sustained
tether and a fixed totem offer two distinct ways to stop healing.

**Life Current (20s CD):** 1.5s water thread, then 6s of healing one-quarter
matched hit per second while the attendant stays within 6 blocks and line of
sight. More than 1s beyond that reach breaks it, giving 2.5s trial boss recovery.
**Spirit Totem (24s CD):** 1.8s rising wood-and-light marker, two-hit totem,
4-block aura lasting 7s. Its healing pulses at 2s intervals, each one-quarter
matched hit. The totem and tether share one pulse allowance: standing in both
does not double healing. Breaking the totem interrupts the current pulse.

**Escalation:** Guardian Flight reaches the totem before the next current,
leaving a full landing pause to separate the attendant. No new attendant.

**Voice:** Open: “A current can carry strength only while its course remains open.”
Half: “The source is there. The tether still has a limit.”
Win: “You found where the current could no longer flow.”
Loss: “The totem could be broken; the tether could be stretched.”

## lifewarden — Before the Seed Opens

**Equipment and lesson:** scythe, leaf mantle, one attendant. Sustained care and
a heavy-hit-triggered shield create a choice between targets and attack weight.

**Renewing Bond (22s CD):** 1.6s green tether for 7s, one-quarter matched hit
healing every 1.5s, broken after 1s beyond 7 blocks. **Sheltering Seed (24s CD):**
1.8s seed formation on the attendant; for 5s the next heavy hit gives a one-hit
shield after damage resolves. No trigger on light hits or an expired seed.
The budding seed is visible and target-specific. Strike the trial boss instead,
break the bond through distance, or deliberately spend the shield. Each expired
or consumed seed gives the trial boss 2.5s of unguarded tending recovery.

**Escalation:** Guardian Flight places the trial boss on the far side of the
bond, so the challenger can choose which direction stretches it. Healing remains
budgeted; the seed never becomes a heal or repeats on every hit.

**Voice:** Open: “A seed waits for its season. Watch what makes this one open.”
Half: “The bond is longer now, but it can still be strained.”
Win: “You understood the care before choosing where to strike.”
Loss: “The seed answered a heavy blow. You had other ways to spend that moment.”

## grovekeeper — The Garden's Edge

**Equipment and lesson:** scythe, branch crown, two attendants. Distinguish a
healing garden from a thorn boundary; neither occupies the entire arena.

**Verdant Bloom (24s CD):** 1.8s buds outline a fixed 4-block garden for 6s,
healing occupants one-quarter matched hit every 2s. **Thorn Ward (22s CD):**
1.6s thorns trace only the garden's outer 1-block annulus, then persist 4s.
An obvious 90-degree gate stays open. Allies inside also receive a one-hit
shield once per ward, never refreshed by a thorn pulse. Touching thorns deals 0.35 hit, at most
twice per cast; the center is not secretly damaging. Each of two root stakes
takes one matched hit; breaking both ends garden and ward, with 3s trial boss
recovery. Lure attendants through the gate or remove the roots.

**Escalation:** Guardian Flight starts the next garden elsewhere only after
the old one fades. No permanent thorn patches or damage behind visual expiration.

**Voice:** Open: “A garden protects what grows within it. It still needs an open gate.”
Half: “New roots. Look for the path I have left you.”
Win: “You found the edge without losing sight of the roots.”
Loss: “The gate was open, and the roots were within reach.”

## shepherd — Gather Without Crowding

**Equipment and lesson:** spear with a pastoral pennant, three attendants. Nearby allies
increase a support effect, and separating them directly reduces its value.

**Gather (22s CD):** 1.6s three gentle bell calls, visible approach routes and
3s of movement with 25% protection. Attendants do not attack during approach.
**Guardian Chorus (24s CD):** 2s audible three-part chord, healing one-quarter
matched hit per nearby attendant to each participant within 5 blocks, capped
at three contributions and the fight budget. A separated singer's note drops
out immediately. Interrupt with two matched hits, or draw one singer away.
Channel recovery 3s; the trial boss has no passive protection from the chorus.

**Escalation:** Guardian Flight reaches the most isolated attendant before
Gather, forcing a new readable gathering location. Defeated attendants do not
return and their missing voices permanently reduce Chorus.

**Voice:** Open: “Listen to the chorus. Every voice near me changes what it can do.”
Half: “Some voices are farther away. That changes the song.”
Win: “You heard the difference one missing voice could make.”
Loss: “You fought us where every voice could answer.”

## spiritcaller — Hear the Echo End

**Equipment and lesson:** mace, ancestral mask, two attendants. An echo is a
second scheduled event which can be denied, not instant duplicate healing.

**Ancestral Echo (24s CD):** 2s channel heals one attendant one matched hit,
then leaves a visible echo at the trial boss's captured location for 3s. The
echo repeats half that heal only if the recipient remains within 5 blocks and
the one-hit echo focus survives. **Spirit Link (22s CD):** 1.6s linking beads,
6s split of 30% attendant damage onto the trial boss, once only per originating
hit. It creates no damage loop or net damage immunity. Separate by 7 blocks
to break the link and cause 2.5s trial boss recovery.

**Escalation:** Guardian Flight moves the trial boss away from the old echo;
the echo itself stays fixed. The challenger chooses link pressure or echo denial.

**Voice:** Open: “A kindness can echo. Listen for where the first voice leaves it.”
Half: “I can move. The echo I left behind cannot.”
Win: “You heard both the voice and the silence that followed.”
Loss: “The echo had a place, a delay, and a focus you could reach.”

## mistweaver — Cross the Tide

**Equipment and lesson:** trident, pale blue robes, two attendants. One moving
wave helps allies and hurts foes; clear edges matter more than dense fog.

**Restorative Tide (22s CD):** 1.8s preparation traces a 5-block-wide wave
traveling 8 blocks over 2.5s. It heals each attendant once for half a matched
hit and deals 0.65 hit to the challenger at most once. Move across its travel
line, not with it. Sparse water ribbons leave the floor visible. **Veilstep
(20s CD):** 1.5s two clear destination pillars, then a 4-block reposition to
one indicated pillar, cleansing the trial boss once and granting 25% protection
for 2s. The selected pillar brightens before movement. Recovery 2.5s.

**Escalation:** Guardian Flight reaches an attendant before the next Tide,
making its orientation relevant. Flight and Veilstep share the mobility lock;
they cannot chain into an uncatchable retreat.

**Voice:** Open: “The same tide can carry help and danger. Watch its course.”
Half: “I will change the shore it begins from. The water still shows the way.”
Win: “You crossed the current without being carried by it.”
Loss: “A step across the wave would have cost less than running with it.”

## soulwarden — What We Carry Together

**Equipment and lesson:** scythe, ancestral shield, two attendants. Shared damage
must remain transparent and conserve damage rather than creating an opaque tank.

**Communion (24s CD):** 1.8s three visible soul threads, then 6s of 40% damage
redistribution among the living linked actors, with total damage conserved and
no recursive re-sharing. Each link breaks beyond 6 blocks for 1s. **Ancestral
Intervention (once per attendant):** below 30% recipient health, a 2s visible
channel attempts a one-hit heal and a one-hit shield, within the fight budget.
Two matched hits interrupt; defeated recipients are never revived. Recovery 3s.

**Escalation:** Guardian Flight reaches the most threatened attendant before
the remaining intervention. Breaking all links causes a 3s trial boss exposure;
focusing the trial boss through redistribution is also viable. The shield never
prevents a fatal hit before the announced channel completes.

**Voice:** Open: “A burden can be shared. That does not make it disappear.”
Half: “Watch which thread is carrying the most weight.”
Win: “You understood what joined us, and what each of us still had to bear.”
Loss: “The threads showed where the damage traveled. Distance could change it.”
