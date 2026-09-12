# Player-data serialization benchmark

This opt-in JMH 1.37 benchmark compares the current `PlayerDataJsonCodec` with
EliteMobs' former Java Serialization + Base64 storage format. It also measures
raw Java Serialization to expose the cost of Base64. It does not touch a server,
database, real player data, or the production JAR.

[Measured results on 2026-09-12](2026-09-12-m3-pro/RESULTS.md), including raw data
and a longer follow-up for the initially inconclusive typical deserialization.

Run correctness tests before interpreting performance:

```sh
java -classpath gradle/wrapper/gradle-wrapper.jar org.gradle.wrapper.GradleWrapperMain \
  --no-daemon test \
  --tests com.magmaguy.elitemobs.playerdata.database.SerializationEquivalenceTest \
  --tests com.magmaguy.elitemobs.playerdata.database.PlayerDataJsonCodecTest

java -classpath gradle/wrapper/gradle-wrapper.jar org.gradle.wrapper.GradleWrapperMain \
  --no-daemon serializationBenchmark
```

The benchmark uses the existing Java 25 test toolchain and project dependencies;
JMH and its annotation processor belong only to the benchmark source set. The
EliteMobs 10.9.0 source requires a matching MagmaCore 2.2.0-SNAPSHOT (the local
run used upstream `59d7bfa19c7f3b8131371842d955cec743b05c57`) and FMM 2.12.0.
Check the recorded Gson source as well as Gradle dependency resolution: the FMM
JAR can bundle its own Gson, which may load before the separately resolved JAR.

JMH options can narrow or lengthen a run, for example:

```sh
java -classpath gradle/wrapper/gradle-wrapper.jar org.gradle.wrapper.GradleWrapperMain \
  --no-daemon serializationBenchmark \
  '-PbenchmarkArgs=-p profile=TYPICAL -f 3 -wi 5 -i 8'
```

Results are written to `build/reports/benchmarks/`:

- `serialization.json`: raw JMH results, per-fork measurements, confidence
  intervals, JVM flags, allocation rate and GC statistics.
- `serialization-sizes.csv`: the exact byte size of each of the four columns.
- `serialization-environment.properties`: actual JVM/OS and loaded Gson JAR.

Each run replaces these files. Archive them together before another run.

## Workload and interpretation

One measured operation processes **all four structured columns of one player**:
quests, quest cooldowns, dungeon boss lockouts and quest lockouts. Each column
has its own stream/document, matching storage boundaries. Serialization returns
four byte arrays ready for JDBC; deserialization consumes pre-encoded arrays
and returns four reconstructed values. Stream construction, JSON validation,
UTF-8 conversion and restoration of quest back-references are included.
Fixture construction, SQL, networking, migration backups and Bukkit lifecycle
side effects are excluded. The elapsed time is not server tick time or database
throughput, and the four fields are not necessarily saved together in gameplay.

| Synthetic profile | Quests | Quest cooldowns | Boss lockouts | Quest lockouts |
|---|---:|---:|---:|---:|
| EMPTY | 0 | 0 | 0 | 0 |
| TYPICAL | 5 | 16 | 32 | 64 |
| HEAVY | 30 | 128 | 256 | 512 |

`TYPICAL` is a chosen example, not a measured median of production players.
`EMPTY` means four non-null empty objects, not SQL NULL. A SQL NULL load can
bypass deserialization and is not represented by this timing.

`JAVA_BASE64` uses the former upstream reader (plain `ObjectInputStream`) and
the existing unchanged `ObjectSerializer.toString` writer, including Base64
and UTF-8 storage conversions. It intentionally does not time the new migration
reader's UID repair or filtering. That reader is checked for compatibility in
the correctness tests. `JAVA_RAW` uses the same Java object stream without
Base64. These original, unfiltered readers are **test-only** and consume only
generated fixtures.

Defaults: one worker thread, two independent JVM forks per parameter combination,
three 1-second warmup iterations, five 1-second measurement iterations, G1 GC
and a fixed 512 MiB heap. JMH consumes returned results to prevent dead-code
elimination. Values are average microseconds per operation; smaller is faster.
Compare both the means and confidence intervals, and distinguish serialized
bytes from total allocated bytes per operation. No speed threshold is asserted
in JUnit: correctness should not depend on machine load.

The harness follows OpenJDK's [JMH setup and review guidance](https://github.com/openjdk/jmh),
[forking sample](https://github.com/openjdk/jmh/blob/1.37/jmh-samples/src/main/java/org/openjdk/jmh/samples/JMHSample_12_Forking.java)
and [GC allocation profiler](https://github.com/openjdk/jmh/blob/1.37/jmh-core/src/main/java/org/openjdk/jmh/profile/GCProfiler.java).
