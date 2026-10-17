# Passive classes and arena difficulty release

`passive-classes-10.9.8.patch` is the maintained source change for the installed
EliteMobs 10.9.8 baseline, upstream commit
`af46989ba2ec64609f39901dc5071bdd9d4a04c7`. It makes classes passive while retaining
native progression, class selection, weapon identity, dungeon authorization and
weapon abilities.

`10.9.8-ruscrafting.2` also adds first-wave enemy level selection to the native
arena menu. It preserves all wave/reward transitions and locks the choice on
first successful admission. Raised difficulty propagates to boss phases and
summons, with the configured `Arenas.yml` `maximumEnemyLevel` ceiling (200 by
default). Authored difficulty remains unchanged. Player-facing menu strings
are configurable in `menus/arena_menu.yml`. Arena content references and Russian
menu overrides are maintained separately in the operations repository.

Build with `bash scripts/build-passive-classes.sh`. The helper reconstructs the
exact upstream sources, checks and applies the text patch, then runs the upstream
Gradle build. It does not modify a JAR or use the older persistence implementation
in the repository root. The upstream license remains in the reconstructed sources.
Extra arguments select Gradle tasks, for example focused `test --tests ...` checks.

The release identity consists of this repository's published commit, the pinned
upstream commit and the patch SHA-256. Build output includes these source inputs
and the final JAR checksum under `build/passive-classes/<patch-sha256>/`.
Build and source directories are retained for inspection after a failure.

Update the patch from a clean worktree at the pinned upstream commit with
`git diff --binary HEAD`, including new files with `git add -N <owned-path>` first.
Do not regenerate it from the unrelated persistence baseline in the repository
root. A new upstream version needs an explicit source comparison and new pin;
never advance the baseline during a build.
