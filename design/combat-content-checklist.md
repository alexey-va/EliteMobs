# Combat content implementation checklist

Tracks MagmaGuy's approved work from 8 September 2026. Checked implementation
does not imply gameplay acceptance. Compile and normal 26.2 deployment are
authorized; new Autotester runs and repository tests are not.

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
- [ ] Derive explicit formulas from evidence and document sparse-data fallbacks.
- [ ] Add editable YAML settings using the existing configuration conventions.
- [ ] Generate the appropriate difficulty/rank version from one item definition.
- [ ] Retain per-item name/lore and fully authored custom loot alongside coverage.
- [ ] Cover all supported class weapon families with deliberate equivalents.
- [ ] Compile, commit, deploy and check registration/configuration.
- [ ] MagmaGuy's thorough manual balance and content review.

Analysis source starts with immutable DLC generation
`20260907T031342379Z-d4164626b272-61c37e91`, 58 packages, manifest
`d4164626b272f603309064adc1b0e1dbaf7758accc9a2213c8519fe05909ec12`.
Do not modify or publish DLC as part of this analysis.

## Item-specific magic enchantments

- [ ] Block Punch on both wands and staves in generation and upgrade paths.
- [ ] Implement wand Multicast: I = 2 bolts at 75% each; II = 2 at 85%;
      III = 3 at 70%. Prefer distinct targets, reuse targets when necessary.
      Level II is an implementation judgment; I and III follow the request.
- [ ] Make Multicast III rare in generated loot and configurable.
- [ ] Implement staff blast-radius enchantment with bounded radius scaling.
- [ ] Implement staff ignition enchantment with bounded duration and damage.
- [ ] Use the existing enchantment configuration, item lore and upgrade systems.
- [ ] Preserve projectile collision, target policy and zero wand knockback.
- [ ] Compile affected FMM/EliteMobs, commit, deploy and check startup.
- [ ] Manual projectile count, split targets, damage, AoE and fire verification.

Additional enchantment ideas must have actual implemented effects before entering
generated loot. Candidate ideas for review: wand travel speed or range; staff
fireball speed. Do not add unimplemented enchantment labels.

## Authored class-trial bosses

- [ ] Read and retain all 75 approved encounters in the linked design documents.
- [ ] Replace the generic player-ability conversion using existing Lua powers.
- [ ] Load/validate each asset and equipment before accepting entry/payment.
- [ ] Implement the five roots with equipment, timelines, visuals and dialogue.
- [ ] Implement Paladin's 14 branch encounters.
- [ ] Implement Berserker's 14 branch encounters.
- [ ] Implement Ranger's 14 branch encounters.
- [ ] Implement Cleric's 14 branch encounters.
- [ ] Implement Spellcaster's 14 branch encounters.
- [ ] Preserve sole challenger, external trainer NPC, arena exclusivity, fees,
      prerequisites, unlock/activation, title and audio.
- [ ] Wire death, failure, disconnect, abort and reload cleanup into trial teardown.
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
- [ ] Find the Nightbreak Discord `nightbreak_crew` channel in the authenticated UI.
- [ ] Post the final builds and briefing, with real mentions for Dali and Frost.
- [ ] Reload/inspect the channel to verify messages, mentions and jar attachments
      persisted; record message links and exact artifact hashes.

This is explicit authority to send these staff messages and attachments. It is
not authority to publish a public plugin/DLC release. The user is sleeping;
use informed judgment and preserve the promised manual review afterward.
