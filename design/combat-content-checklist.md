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

- [x] Read and retain all 75 approved encounters in the linked design documents.
- [x] Replace the generic player-ability conversion using existing Lua powers.
- [x] Author shared mobility powers once for the classes that inherit them (syntax compiled; integration and gameplay pending).
- [x] Load/validate each asset and equipment before accepting entry/payment.
- [x] Author the five root scripts with equipment, timelines, visuals and dialogue (syntax compiled; integration and gameplay pending).
- [x] Author Paladin's 14 branch encounters (syntax compiled; integration and gameplay pending).
- [x] Author Berserker's 14 branch encounters (syntax compiled; integration and gameplay pending).
- [x] Author Ranger's 14 branch encounters (syntax compiled; integration and gameplay pending).
- [x] Implement Cleric's 14 branch encounters (syntax compiled; gameplay pending).
- [x] Implement Spellcaster's 14 branch encounters (syntax compiled; gameplay pending).
- [x] Preserve sole challenger, external trainer NPC, arena exclusivity, fees,
      prerequisites, unlock/activation, title and audio.
- [x] Implement death, failure, disconnect, abort and reload cleanup through the
      combat object's existing close hook, without editing arena orchestration.
- [x] Compile, commit, deploy and inspect all asset registration diagnostics.
- [ ] Manual acceptance cases in `class-trial-runtime.md` and all encounter reviews.

Canonical approved references: `class-trial-runtime.md`,
`class-trial-encounters.md`, and the five `class-trials-<root>.md` files.
No generic encounter is an acceptable fallback for an unfinished authored asset.

## Final staff delivery, explicitly authorized by MagmaGuy

- [x] Finish the requested v0 autonomously, including all earlier checklist areas.
- [x] Compile final EliteMobs, ResourcePackManager and FreeMinecraftModels jars
      and verify the exact artifacts. All three are explicitly requested.
- [x] Establish each plugin's previous full public release from current evidence.
- [x] Review every net change since that release, including existing WIP changes.
- [x] Prepare a substantial per-plugin changelog as chat text, not repository files.
- [x] Explain the major admin tools, including mob brains, verified mob/NPC patrol
      support, combat/resources/controls, class trials and automatic class loot.
- [x] Give practical setup instructions and verified YAML/command examples for
      each major tool, with relevant limitations and manual-test caveats.
- [x] Include the staff test workflow: loot debug grants/unlocks classes at the
      selected level; class-forget debug removes an unlock to retest its trial.
      Verify exact command syntax and prerequisite/descendant behavior in source.
- [x] Tell Dali and Frost that the class NPCs are in the Adventurer's Guild and
      their current LibsDisguises appearances are placeholders requiring finalization.
- [x] Find the Nightbreak Discord `nightbreak_crew` channel in the authenticated UI.
- [x] Post the final builds and briefing, with real mentions for Dali and Frost.
- [x] Reload/inspect the channel to verify messages, mentions and jar attachments
      persisted; record message links and exact artifact hashes.

This is explicit authority to send these staff messages and attachments. It is
not authority to publish a public plugin/DLC release. The user is sleeping;
use informed judgment and preserve the promised manual review afterward.


## Implementation and delivery checkpoints (chronological)

Automatic class loot: EliteMobs `53b1b9c03`, deployed to 26.2. MagmaDeck PID
92804, restart at 08:12 local, EliteMobs initialized at 08:12:28. Runtime logged
90 class-loot profiles loaded and the effect settings appear in enchantment YAML.
Deployed EM SHA-256: `888F749853878C58A49AFA9ED5158DB42EA43C6EAF55854A73C2F1E2C345015B`.
Backup: `%TEMP%/elitemobs-class-loot-20260908-080850`.

All 75 authored Lua encounters pass canonical syntax/hook compilation. The old
generic ClassTrialCombat implementation has been replaced with a LuaElitePower
binding and TrialScriptActor. Equipment, thematic armor dyes, dialogue and boss
health come from explicit per-form metadata. Spellcaster weapons use canonical
FMM magic identity/presentation. Assets register on startup and equipment is
preflighted before the existing admission code charges the attempt fee.

Java compilation and a deployable shadowJar pass. No arena code/configuration,
world, admission, reservation or teardown orchestration was changed. Existing
challenge closure shuts down scripts, missiles, temporary effects, summoned
actors and pose/movement state; an inactive Lua runtime reaches the existing
failure/refund path. This is source and build evidence, not gameplay acceptance.

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


Spellcaster checkpoint: all 14 branches are authored, including breakable spell
echoes, committed elemental stages, brazier-controlled fire, a bounded frost
storm with clear ground, conjured blade sequences, finite corpse/portal charges,
shared wards and damage links. Summons have explicit lifetimes and attack tells;
healing has finite budgets. All 75 Lua assets compile after integration. Physical
movement, curved arrows, collision, helper hitboxes, resource-pack presentation
and every encounter's balance still require the requested manual pass.

Authored-trial deployment: 26.2 restarted through MagmaDeck at 09:43 local,
PID 21832. At 09:43:58 the server logged "Validated 75 authored class-trial
encounters" and "EliteMobs fully initialized". EM SHA-256:
`D8131A3CAD4F774EFD509B0C38AE14977F6E1CEBE431654138CC8B3BB6C394F5`.
FMM API5 SHA-256: `A844E77514112E58946EF2743DE397096F830C7A83E35CF1B562B6DFE6562D1F`.
Backup: `%TEMP%/elitemobs-authored-trials-20260908-094336`.
Startup still has the existing Windows Perflib/OSHI errors. The current Geyser
build also lacks BedrockEntityDefinition, so RSPM disables its custom Bedrock
entity bridge with an explicit diagnostic. Neither is evidence of gameplay
acceptance; no client or Autotester run was performed for this checkpoint.

Final delivery, verified 8 September 2026 at 09:56 local:

- Private staff post: https://discord.com/channels/320602228669022208/1008771253747855401/1546805531229032488
- Twelve posts total: build introduction plus eleven per-plugin/administrator
  briefing sections. Dali_ and Frost were selected through member autocomplete;
  both rendered as clickable mentions after reloading the channel.
- All three attached JARs were downloaded from their posted attachment URLs and
  their SHA-256 hashes matched the immutable staged builds byte for byte.
- EM: `D8131A3CAD4F774EFD509B0C38AE14977F6E1CEBE431654138CC8B3BB6C394F5` (8,955,118 bytes).
- FMM: `A844E77514112E58946EF2743DE397096F830C7A83E35CF1B562B6DFE6562D1F` (4,497,223 bytes).
- RSPM: `B5BDAD083D270B4ACFFF7093F550DCF992550E84D893FCA6BC68B6144C624167` (6,543,899 bytes).
- Staging and verification receipts: `%TEMP%/nightbreak-staff-20260908-0947/`.
  `discord-receipts.json` contains reloaded server message IDs; provisional
  composer IDs changed after server acceptance and were reconciled without
  resending. `delivery-verification.json` records all attachment hashes.
- Public baselines corroborated through release-pipeline status: EM 10.8.1
  (`5981bfe49`), FMM 2.11.2 (`98eeb49`), RSPM 2.3.1 (`1c70097`). Modrinth and
  Reposilite agreed; the status tool could not resolve Spigot. The briefing
  covers net code/working-tree features and applicable shared behavior; it does
  not promote test-only WIP work into user-facing claims.
- Final three-JAR testbed set restarted via MagmaDeck at 09:48, PID 76400.
  At 09:48:30 the catalog validated all 75 encounters; EM and RSPM finished
  initialization at 09:48:31. The existing Perflib/OSHI errors and incompatible
  Geyser custom-entity bridge diagnostic remain explicitly noted.
- The staff received exact debug commands, class prerequisite/reset caveats,
  current controls, resource rates, loot and patrol YAML examples, and the
  distinction between native Mind integration APIs and an absent admin YAML
  loader. They were told the AG class NPC disguises are placeholders to finalize.
- No arena orchestration/world/config changes, public publication, pushes,
  Autotester runs or new client tests were performed in this implementation batch.

The autonomous v0 and staff delivery are complete. Open manual-check boxes above
are the explicitly retained player-facing acceptance and balance work, not
claims of tests that ran.
