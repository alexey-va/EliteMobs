# RusCrafting persistence hotfix

This fork fixes a server-thread stall observed in EliteMobs 10.8.1: an online
mob-kill update waited behind JDBC while acquiring the player-data monitor.
The write queue and player hydration state now use short separate locks.
The database connection stays serialized. Deferred hydration updates are
replayed outside the state lock and the player is published only after those
writes have been read back. Shutdown still drains queued writes.

No currency rates, reward quantities, database schemas, menus, or content are
changed. Existing currency-shower configuration remains operator-owned.

The verified running JAR reports 10.8.1; upstream master currently declares
10.8.0 and targets Spigot 26.2. To avoid an unrelated platform/content upgrade,
`build_patch.py` compiles only PlayerData and PlayerDataRepository against the
verified binary and Paper 1.21.11 API, then replaces their class families.
All other uncompressed JAR entries are asserted byte-identical. The script
checks the baseline SHA-256, package/public ABI, clean source paths, ZIP
integrity and duplicate entries; revision and dependency hashes are embedded
in META-INF/ruscrafting-patch.json. The result is 10.8.1-ruscrafting.1.

Baseline SHA-256:
`aac94a889701633d1746aa81646ddf05c1b0a8d1ce6b37fcdd69b011da766d24`.
The baseline is supplied by the operator; it is not downloaded from arbitrary
mirrors or committed to this source repository. Full upstream builds continue
to use build.gradle. The hotfix build does not publish Maven artifacts.

Run the fast JDBC-contention and queue regression without a server:

```sh
python3 ruscrafting/test_persistence.py
```

Compile with JDK 21+ and a classpath containing the verified baseline's Paper
1.21.11 API, Lombok 1.18.38, Adventure API/key 4.25.0, examination-api 1.3.0,
JetBrains annotations 26.0.2 and jsr305 3.0.2:

```sh
python3 ruscrafting/build_patch.py --base-jar /absolute/EliteMobs-10.8.1.jar \
  --classpath "$PATCH_COMPILE_CLASSPATH" --lombok /absolute/lombok-1.18.38.jar \
  --output /absolute/EliteMobs-10.8.1-ruscrafting.1.jar
```

Deploy only through the operations repository's descriptor-aware `mc jar`
workflow. The diagnosed target is spawn (`classic`). Survival's different
10.7.3 baseline is outside this patch's compatibility contract.

## Wormhole return after leaving the dungeon

If a player teleports out before walking away from the arrival wormhole,
EliteMobs used to retain its "still inside the portal" state in the other world.
Changing worlds now counts as leaving that radius. The normal time cooldown
still applies. An unloaded destination also cannot keep the player inside its
radius. This allows an ordinary wormhole entry after leaving an open dungeon;
ARC then restores the saved departure coordinates.

The `wormhole` profile replaces only `WormholeManager$PlayerWormholeData`,
preserving the earlier JDBC fix and all other binary entries. Its baseline is
the exact `10.8.1-ruscrafting.1` candidate with SHA-256
`404e31c5018c0e30add28fc56fea4aa844864df59a27cdc13d697838c17a5d15`.
The output reports `10.8.1-ruscrafting.2` and keeps both provenance manifests.
Use the classpath above plus the Paper runtime's BungeeCord chat API:

```sh
python3 ruscrafting/build_patch.py --patch wormhole \
  --base-jar /absolute/EliteMobs-10.8.1-ruscrafting.1.jar \
  --classpath "$PATCH_COMPILE_CLASSPATH" --lombok /absolute/lombok-1.18.38.jar \
  --output /absolute/EliteMobs-10.8.1-ruscrafting.2.jar
```

This profile is scoped to the verified `classic` binary; it does not upgrade
the separate Survival baseline.
