# EliteMobs persistence

The current fork stores dungeon respawn/restock timers in namespaced SQL tables
and the four structured player columns as version 1 UTF-8 JSON. Both SQLite and
MySQL use the same codec. Config YAML contains content definitions; frequent
runtime changes go to the database.

Player hydration and structured reads abort on non-null unreadable data instead
of publishing empty quest/lockout state. SQL NULL still means a new empty state.
Legacy Java payloads are read only for migration. UID repair runs at actual JDK
class-descriptor boundaries and preserves the stream field schema; explicitly
versioned classes keep their normal compatibility checks.

Migration processes 100 players per transaction, saves original byte snapshots,
and compares the source bytes before replacing a value. `PlayerDataSerializedSnapshots`
keys backups by player plus SHA-256 of the complete snapshot, so another legacy
write from an older server gets its own backup. The earlier
`PlayerDataSerializedLegacy` table is retained unchanged. No YAML fallback is used.

Dungeon writes coalesce by key, share the player's JDBC connection lock, and are
acknowledged only after commit. Failed batches remain queued with bounded retry
backoff; newer values survive acknowledgment of older writes. Shutdown attempts a
final flush and logs an explicit failure if the database remains unavailable.

Run the focused persistence suite and build with Java 21+:

```sh
java -classpath gradle/wrapper/gradle-wrapper.jar org.gradle.wrapper.GradleWrapperMain \
  --no-daemon test shadowJar -PruscraftingVersion=10.8.2-ruscrafting.6
```

RusCrafting's build adds its existing private MagmaCore repository/substitution
init script: immutable coordinate
`ru.ruscrafting.thirdparty:magmacore:2.2.0-20260910.27ce503-ruscrafting.1`.
The version property changes the packaged descriptor without editing the JAR.

`PlayerDataReadOnlyAudit` in the test source set is a standalone, read-only
semantic round-trip check. Run it on the database host using the exact platform
libraries from the active server's `META-INF/libraries.list`, the plugin JAR and
the compiled audit class. It accepts JDBC URL and username as arguments and
`ELITEMOBS_AUDIT_PASSWORD` from the process environment. It outputs aggregate
counts only; it never exports player identifiers or payloads.

The compatibility reader uses the JDK's
[readClassDescriptor boundary](https://docs.oracle.com/en/java/javase/21/docs/api/java.base/java/io/ObjectInputStream.html#readClassDescriptor()).
Database conflict handling uses native SQLite UPSERT and
[MySQL ON DUPLICATE KEY UPDATE](https://dev.mysql.com/doc/refman/8.4/en/insert-on-duplicate.html),
without INSERT IGNORE suppressing unrelated backup errors.

# Historical 10.8.1 hotfix

The binary patch procedure below applies to commit `dbc8e884`, not the current
source. Current builds use the full Gradle build documented above.

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
