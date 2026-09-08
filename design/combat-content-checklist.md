# Combat content implementation checklist

Tracks MagmaGuy's approved work from 8 September 2026. Checked implementation
does not imply gameplay acceptance. Compile and normal 26.2 deployment are
authorized; new Autotester runs and repository tests are not.

**Scope restriction:** Do not modify the arena: code, configuration, layout/world,
admission, fees, reservation or teardown orchestration. Boss content must use
existing trial entry points. This later user instruction takes precedence over
earlier arena-related implementation suggestions.

## Default generated magic loot

- [x] Add enabled-by-default staves/wands to procedural drops and shops.
- [x] Gate generated magic loot on its individual setting and operational FMM.
- [x] Preserve weapon skill, model, durability and supported enchantments.
- [x] Apply the same availability checks to baseline class loot.
- [x] Compile, commit and deploy to 26.2 through MagmaDeck.
- [x] Verify startup and generated configuration.
- [ ] Manual drop, shop, disabled-setting and unavailable-FMM gameplay pass.

Implementation checkpoint: EliteMobs `afd4a54eb`. 26.2 restarted at 07:33 local,
PID 65712. Prior jar/config backup is in the Windows temp directory named
`elitemobs-dynamic-magic-loot-20260908-073310`.

## DLC evidence and automatic class loot

- [x] Inventory the entire available DLC generation, including coverage gaps.
- [x] Resolve actual item-to-mob loot references, difficulty and mob rank; retain unresolved references explicitly.
- [x] Report enchantment medians, prevalence and sample sizes by difficulty,
      trash/miniboss/boss and weapon family; separate inferred classifications.
- [x] Derive explicit formulas from evidence and document sparse-data fallbacks.
- [x] Add editable YAML settings using the existing configuration conventions.
- [x] Generate the appropriate difficulty/rank version from one item definition.
- [x] Retain per-item name/lore and fully authored custom loot alongside coverage.
- [x] Cover all supported class weapon families with deliberate equivalents.
- [x] Compile, commit, deploy and check registration/configuration.
- [ ] MagmaGuy's thorough manual balance and content review.

Analysis source starts with immutable DLC generation
`20260907T031342379Z-d4164626b272-61c37e91`, 58 packages, manifest
`d4164626b272f603309064adc1b0e1dbaf7758accc9a2213c8519fe05909ec12`.
Do not modify or publish DLC as part of this analysis.

## Item-specific magic enchantments

- [x] Block Punch on both wands and staves in generation and upgrade paths.
- [x] Implement wand Multicast: I = 2 bolts at 75% each; II = 2 at 85%;
      III = 3 at 70%. Prefer distinct targets, reuse targets when necessary.
      Level II is an implementation judgment; I and III follow the request.
- [x] Make Multicast III rare in generated loot and configurable.
- [x] Implement staff blast-radius enchantment with bounded radius scaling.
- [x] Implement staff ignition enchantment with bounded duration and damage.
- [x] Use the existing enchantment configuration, item lore and upgrade systems.
- [x] Preserve projectile collision, target policy and zero wand knockback.
- [x] Compile affected FMM/EliteMobs, commit, deploy and check startup.
- [ ] Manual projectile count, split targets, damage, AoE and fire verification.

Additional enchantment ideas must have actual implemented effects before entering
generated loot. Candidate ideas for review: wand travel speed or range; staff
fireball speed. Do not add unimplemented enchantment labels.

## Authored class-trial bosses

- [ ] Read and retain all 75 approved encounters in the linked design documents.
- [ ] Replace the generic player-ability conversion using existing Lua powers.
- [x] Author shared mobility powers once for the classes that inherit them (syntax compiled; integration and gameplay pending).
- [ ] Load/validate each asset and equipment before accepting entry/payment.
- [x] Author the five root scripts with equipment, timelines, visuals and dialogue (syntax compiled; integration and gameplay pending).
- [x] Author Paladin's 14 branch encounters (syntax compiled; integration and gameplay pending).
- [x] Author Berserker's 14 branch encounters (syntax compiled; integration and gameplay pending).
- [x] Author Ranger's 14 branch encounters (syntax compiled; integration and gameplay pending).
- [ ] Implement Cleric's 14 branch encounters.
- [ ] Implement Spellcaster's 14 branch encounters.
- [ ] Preserve sole challenger, external trainer NPC, arena exclusivity, fees,
      prerequisites, unlock/activation, title and audio.
- [ ] Implement death, failure, disconnect, abort and reload cleanup through the
      combat object's existing close hook, without editing arena orchestration.
- [ ] Compile, commit, deploy and inspect all asset registration diagnostics.
- [ ] Manual acceptance cases in `class-trial-runtime.md` and all encounter reviews.

Canonical approved references: `class-trial-runtime.md`,
`class-trial-encounters.md`, and the five `class-trials-<root>.md` files.
No generic encounter is an acceptable fallback for an unfinished authored asset.

## Final staff delivery, explicitly authorized by MagmaGuy

- [ ] Finish the requested v0 autonomously, including all earlier checklist areas.
- [ ] Compile final EliteMobs, ResourcePackManager and FreeMinecraftModels jars
      and verify the exact artifacts. All three are explicitly requested.
- [ ] Establish each plugin's previous full public release from current evidence.
- [ ] Review every net change since that release, including existing WIP changes.
- [ ] Prepare a substantial per-plugin changelog as chat text, not repository files.
- [ ] Explain the major admin tools, including mob brains, verified mob/NPC patrol
      support, combat/resources/controls, class trials and automatic class loot.
- [ ] Give practical setup instructions and verified YAML/command examples for
      each major tool, with relevant limitations and manual-test caveats.
- [ ] Include the staff test workflow: loot debug grants/unlocks classes at the
      selected level; class-forget debug removes an unlock to retest its trial.
      Verify exact command syntax and prerequisite/descendant behavior in source.
- [ ] Tell Dali and Frost that the class NPCs are in the Adventurer's Guild and
      their current LibsDisguises appearances are placeholders requiring finalization.
- [ ] Find the Nightbreak Discord `nightbreak_crew` channel in the authenticated UI.
- [ ] Post the final builds and briefing, with real mentions for Dali and Frost.
- [ ] Reload/inspect the channel to verify messages, mentions and jar attachments
      persisted; record message links and exact artifact hashes.

This is explicit authority to send these staff messages and attachments. It is
not authority to publish a public plugin/DLC release. The user is sleeping;
use informed judgment and preserve the promised manual review afterward.


## Current implementation checkpoint

Automatic class loot: EliteMobs `53b1b9c03`, deployed to 26.2. MagmaDeck PID
92804, restart at 08:12 local, EliteMobs initialized at 08:12:28. Runtime logged
90 class-loot profiles loaded and the effect settings appear in enchantment YAML.
Deployed EM SHA-256: `888F749853878C58A49AFA9ED5158DB42EA43C6EAF55854A73C2F1E2C345015B`.
Backup: `%TEMP%/elitemobs-class-loot-20260908-080850`.

The authored trial implementation is still a source-only checkpoint. Five root
Lua programs and their shared mobility programs pass canonical Lua syntax/hook
validation. All 75 presentation YAML files contain explicit equipment and the
approved four dialogue beats. Paladin's 14 branch Lua programs now compile;
Berserker's and Ranger's 14 each are also authored. Cleric's 14 branch programs also pass canonical Lua compilation. The remaining 14 Spellcaster branch programs are not written yet.
`TrialEncounterAssets` validates the whole catalog and has no generic fallback.
It is not wired into `ClassTrialDefinition` / `ClassTrialCombat` yet; those still
contain the rejected old runtime, including on the live testbed. Complete the
branch assets and replacement binding before deployment.

The new trial actor adapter uses normal `LuaElitePower` / `ScriptableBoss` /
`ScriptInstance` lifecycle and hooks. It owns projectiles, sparring actors, poses,
physical movement, damage-budget delivery and temporary spectral panels. Java
compilation passes. No arena code/configuration/world/orchestration was changed.

FMM `a022909` adds the synchronous cancellable magic projectile travel query
(magic API capability 5), needed for the authored spectral walls. It checks
travel and impact before damage/explosion, with no event allocation when there
are no listeners. Built and installed to Maven Local; not yet deployed. Existing
unrelated FMM working changes remain untouched. Latest testbed FMM is still the
previous magic-enchantment checkpoint.

Lua compilation command uses `design/tools/CompileTrialScripts.java` against the
shaded EliteMobs jar and the local Spigot API jar. It invokes canonical
`ScriptDefinition.validate`; it does not start a server, invoke encounter hooks,
or establish behavior. Root scripts compile; manual gameplay remains pending.

Paladin branch checkpoint: actual helper arrows, percentage damage transfer,
finite spectral walls, breakable standard actors, mobile/fixed formation auras,
committed thrusts/arcs, safe displacements and explicit recovery windows are
authored. Java compilation and canonical Lua compilation pass for all 15 Paladin
forms. This remains source-only until the whole 75-form catalog is complete and
the old definition/combat binding is replaced. Berserker designs have been read;
its one-use survival mechanic now has a narrow owned adapter at the normalized
Bukkit damage boundary, preserving the original event and attacker.

Ranger checkpoint: a cohesive `TrialProjectiles` component owns native collision,
cast budgets, impact receipts, explicit penetration targets and fixed curve
steering. Crossbow items switch charged state; volleys share caps; payloads have
separate removable props/fuses; rain clears old arrows before changing its safe
lane. Ordinary ranged attacks no longer backpedal without a mobility cooldown.
Props use the canonical normalized living-entity damage path with an armor-stand
LibsDisguises appearance, rather than vanilla armor-stand break rules. No arena
orchestration, configuration or saved blocks were edited. Java and Lua compile;
physical behavior and balance remain unverified. Cleric designs have been read.

