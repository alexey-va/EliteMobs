# Combat content implementation plan

Approved scope, 8 September 2026. Track completion in
[`combat-content-checklist.md`](combat-content-checklist.md). This plan records
dependencies and decisions; the checklist records progress. Keep both consistent
as implementation reveals facts. The user requested informed decisions in his
absence followed by a thorough manual review, not repeated design approvals.

**Latest restriction:** MagmaGuy explicitly prohibited modifying the arena.
Do not edit arena code, configuration, world/layout, container/reservation logic
or admission/fee/teardown orchestration. Implement boss content through the
existing trial entry points. This restriction supersedes any earlier suggestion
below that would require changing arena infrastructure. If an authored mechanic
cannot fit those entry points, record that specific limitation rather than
expanding the arena system.

## Intended result

Ordinary generated loot includes operational FMM wands and staves by default.
Magic weapons have meaningful, item-specific enchantments using the usual
EliteMobs generation, lore and upgrade systems. Baseline class loot automatically
covers every supported class weapon family at a strength appropriate to the
encounter's difficulty and rank, using measured DLC conventions. One authored
item entry supplies its own name and lore across difficulty variants. All 75
class trials use their approved authored encounter designs instead of the
rejected generic player-ability conversion.

## 1. Preserve the working checkpoint

Complete the procedural magic-loot change, compile, commit, deploy through the
MagmaDeck CLI and inspect startup. Record the installed artifact and backup.
Keep the user's background Autotester untouched. Individual generation settings
default to true and FMM readiness is checked when selecting/constructing loot.
World-specific [Alpha] Advanced Combat System activation does not determine whether a
staff or wand functions.

This checkpoint is implemented in `afd4a54eb`; the checklist records deployment.

## 2. Build reproducible evidence from the DLC corpus

Read the immutable local DLC generation and record its manifest and package list.
Analyse every relevant package, not just Yggdrasil or a representative handful.
Do not edit or publish DLC. Keep the extraction/analysis script and its evidence
in EliteMobs so the results can be reproduced against a future generation.

Resolve actual boss loot references to custom items, including map/string loot
syntax and difficulty restrictions. Normalize legacy enchantment aliases to
current canonical keys. Classify by normal/hard/mythic difficulty, trash,
miniboss or boss rank, and item family. Distinguish explicit metadata from
inference. Record ambiguous references, malformed files, disabled content,
unreferenced items, noncombat items, reinforcements and phased encounter duplicates.

Report sample sizes, enchantment prevalence, median positive level and median
including absence. Report enchantment budgets and item levels. Avoid letting one
item referenced by many copied mobs dominate the authored-item medians; retain
drop-reference statistics separately. Separate difficulty-neutral legacy content
from explicit difficulty variants rather than silently treating all of it as
normal difficulty. Use matched item families across difficulties where possible
to estimate progression without confusing item level and encounter difficulty.

Deliver an evidence report with tables, provenance and explicit coverage gaps.
Do not invent a median for a family/rank/difficulty with no samples.

## 3. Define and implement automatic class-loot profiles

Use the measured medians and paired difficulty comparisons to select explicit
default rules for every difficulty, rank and weapon family. Document judgment
calls, outlier handling and sparse-data fallbacks. The output must answer how
strong a normal/hard/mythic weapon is on trash, minibosses and bosses. Preserve
material/item-level behavior and the plugin's enchantment accounting instead of
adding a second item-power calculation.

Implement an editable YAML configuration through the existing configuration
classes, validation, defaults and reload mechanism. Expose primary enchantment
levels, supported secondary enchantments, occurrence/rarity and caps as needed.
Keep the formula deterministic for a given profile, with randomness limited to
explicitly configured secondary selections. Reject malformed settings with a
specific diagnostic and safe documented behavior.

Class loot must fill missing class weapon coverage automatically. Every item
keeps its own name and lore; never reintroduce shared lore for a whole boss.
Retain one item definition per weapon family and derive the difficulty/rank
version at generation time. Resolve the active encounter difficulty through the
canonical dungeon system. Provide an explicit default for non-instanced content
and a configuration escape hatch where authored content needs a different rank
or profile. Do not require normal/hard/mythic copies of the same item definition.

Keep fully authored custom drops, unusual enchants and bespoke potion effects
available. Do not silently rewrite the DLC's existing item files. Preserve loot
eligibility, contribution rules, party handling, reinforcement exclusions and
administrator-disabled weapon families. Explain the final YAML with concrete
examples and the resulting enchantments for each difficulty.

## 4. Implement magic enchantments and compatibility

First inspect the canonical FMM projectile/cast boundary and EliteMobs enchantment
configuration, item tagging, lore, book generation and upgrading. Pass authored
weapon traits through the existing integration; do not create a competing cast
or projectile engine.

- Remove Punch from generated and upgrade-compatible wands/staves. Legacy items
  must not acquire knockback behavior from an existing Punch enchantment.
- Wand Multicast I fires two bolts at 75% of normal bolt damage each.
- Multicast II fires two bolts at 85% each. This intermediate value is a stated
  judgment for review, since the request specified the endpoints.
- Multicast III fires three bolts at 70% each and is difficult to obtain.
- Prefer different eligible targets, respecting elite/vanilla/player priority,
  cone and range. When targets are scarce, reuse them. Every bolt remains a
  colliding projectile and wand knockback remains zero.
- Staff blast-radius enchantment increases explosion radius with a bounded,
  configurable level progression. Reuse actual explosion geometry for visuals
  and affected-target selection.
- Staff ignition applies bounded fire duration to affected eligible enemies.
  Preserve protection checks and damage attribution. Do not damage blocks or
  introduce fire spread as an unintended enchantment side effect.

Use item-specific compatibility for generated loot and all normal upgrade paths.
Show actual effects in lore/configuration. Make unsupported books refuse cleanly
without consuming currency or ingredients. Keep Power, durability enchants and
other supported existing behavior. Optional ideas for later review are wand
range/projectile speed and staff projectile speed; do not populate loot with
unimplemented labels just to match the number of bow enchants.

Set final coefficients after inspecting damage/cooldown behavior. Document total
Multicast output, per-target output, caps, generation rarity and acquisition
sources. Compile FMM and EliteMobs as needed, then deploy the matching pair.

## 5. Replace the generic class-trial encounters

The approved content already exists in:

- [`class-trial-runtime.md`](class-trial-runtime.md)
- [`class-trial-encounters.md`](class-trial-encounters.md), five roots
- [`class-trials-paladin.md`](class-trials-paladin.md), fourteen branches
- [`class-trials-berserker.md`](class-trials-berserker.md), fourteen branches
- [`class-trials-ranger.md`](class-trials-ranger.md), fourteen branches
- [`class-trials-cleric.md`](class-trials-cleric.md), fourteen branches
- [`class-trials-spellcaster.md`](class-trials-spellcaster.md), fourteen branches

Use authored Lua powers on the existing EliteMobs/MagmaCore runtime. There is no
approved prerequisite to redesign that runtime or introduce a general encounter
scope/target-filter API. Add a narrowly justified operation only when an actual
approved mechanic cannot be expressed with existing operations.

Implement the five roots first, then each branch family. Maintain a per-form
asset checklist. Every encounter needs actual equipment, class-specific attacks,
mobility and utility, committed warnings, recovery/cooldowns, bounded healing and
summons, meaningful response windows, visuals/sounds and instructor dialogue.
The Ranger trial boss must visibly wield and fire a bow. No unequipped Husk or
generic distance-damage fallback counts as an implemented encounter.

MagmaGuy specifically requested shared boss mobility powers where classes inherit
the same mobility skill. Implement each shared mobility mechanic once and have
the appropriate encounters explicitly select it, with their authored timing.
Do not duplicate mount/leap/roll/blink behavior per form or infer the entire fight
from player ability flags. Signature, utility, choreography and dialogue remain
authored per encounter.

The trainer NPC remains outside the arena and handles enrollment. The challenger
is the only admitted player; a separate trial boss fights them. Keep shared Wood
League container exclusivity, solo admission, fees equivalent to 100 same-level
mobs, class skill/mastery prerequisites, admin forget behavior, victory unlock
and automatic activation, title and audio cue. Do not restore class focus/stars.

Use existing pre-admission validation entry points for required assets. A missing or invalid form
must identify its asset to the administrator and must not silently use generic
combat. Use the combat object's existing close hook to shut down Lua and every
temporary actor/projectile/prop for victory, failure, disconnect, abort and reload.
Do not modify the arena's teardown orchestration.
Warnings and hits share geometry. Respect terrain and projectile collision.

Move approved numbers into executable assets as each form is implemented, and
link the design to those assets instead of maintaining two competing balance
definitions. Preserve dialogue tone: instructors assess the challenger; Clerics
encourage, darker classes may be harsh. Intro, phase and victory/failure lines
must respond to the actual encounter state.

## 6. Delivery and manual review

At each coherent checkpoint: inspect the changes, compile/build the affected
repositories, make scoped WIP commits, back up the installed artifacts, deploy
through the existing MagmaDeck server-control CLI and inspect startup/config
diagnostics. Rebuild shaded consumers when a shared library changes. Never push
or publish plugins/DLC without a separate instruction.

Current authorization is compile-only beyond normal deployment inspection. Do
not start repository test suites, Autotester or real clients. Keep explicit
manual-review cases for generated loot distribution, difficulty formulas,
upgrade rejection/costs, Multicast targeting/collision/damage, staff AoE/ignition,
all 75 encounters, early teardown and a subsequent clean Wood League run.

Final reporting must distinguish implemented, compiled, deployed, startup-checked
and gameplay-verified. The user's thorough manual pass remains outstanding until
it actually happens. A build or startup is not evidence of visual polish or fair
balance.

## 7. Final Discord staff handoff

MagmaGuy explicitly authorized sending the completed builds to Dali and Frost in
Nightbreak's `nightbreak_crew` chat. This final step is part of the goal, not an
optional offer. Finish v0 autonomously while he sleeps.

Build the final EliteMobs, ResourcePackManager and FreeMinecraftModels artifacts.
MagmaGuy explicitly requested all three, including RSPM. Determine each plugin's actual last
full public release and review all net source changes since that point, including
pre-existing WIP changes included in the jars. Follow `.claude/rules/releases.md`
for changelog style and baseline rules. This is a private tester/staff delivery,
not public release authorization. Do not create repository changelog files.

Write a substantial staff briefing with per-plugin change bullets and focused
explanations of the big admin tools. Cover mob brains/AI configuration, verified
mob and NPC patrol support, the combat model, health/resources, class controls,
class progression and solo arena trials, automatic class loot and magic item
enchantments. Discover additional major tools in the release comparison rather
than assuming this list is exhaustive. Each important feature needs practical
setup steps and a real configuration or command example. Validate names, paths,
options and examples against the finished code. Distinguish partially implemented
systems, version/dependency requirements and manual-test gaps without burying the
staff in implementation trivia.

Explicitly include MagmaGuy's testing shortcut: the loot debug command grants the
loadout and unlocks classes at its selected level, then the class-forget debug
command removes a chosen unlock so staff can test that class's trial. Verify the
actual command names/arguments, target-player support, prerequisite handling and
descendant reset behavior against the final code. Do not repeat an approximate
command from conversation as if it were tested syntax.

Tell the staff explicitly that the class NPCs are already in the Adventurer's
Guild and their current LibsDisguises appearances are placeholders to finalize.
Do not present the current skins/disguises as approved final art.

Use the existing authenticated Discord UI and the workspace browser procedure.
Locate the exact crew channel and correct Dali/Frost members. Select actual
mentions through autocomplete or another supported UI flow; typed `@name` is not
a ping. Attach the final jars, split the briefing into readable messages as
needed, and verify the posted text, clickable mentions and attachments after a
fresh channel render. Record message links and hashes. If posting is ambiguous,
inspect the channel before retrying to avoid duplicate messages/uploads.
