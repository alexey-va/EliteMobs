package com.magmaguy.elitemobs.playerdata.database;

import com.google.gson.Gson;
import org.openjdk.jmh.annotations.Benchmark;
import org.openjdk.jmh.annotations.BenchmarkMode;
import org.openjdk.jmh.annotations.Fork;
import org.openjdk.jmh.annotations.Measurement;
import org.openjdk.jmh.annotations.Mode;
import org.openjdk.jmh.annotations.OutputTimeUnit;
import org.openjdk.jmh.annotations.Param;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.Setup;
import org.openjdk.jmh.annotations.State;
import org.openjdk.jmh.annotations.Threads;
import org.openjdk.jmh.annotations.Warmup;
import org.openjdk.jmh.profile.GCProfiler;
import org.openjdk.jmh.results.format.ResultFormatType;
import org.openjdk.jmh.runner.Runner;
import org.openjdk.jmh.runner.options.CommandLineOptions;
import org.openjdk.jmh.runner.options.OptionsBuilder;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;
import java.util.Properties;
import java.util.concurrent.TimeUnit;

/** One operation processes the four structured columns of one synthetic player. No JDBC or server. */
@State(Scope.Thread)
@BenchmarkMode(Mode.AverageTime)
@OutputTimeUnit(TimeUnit.MICROSECONDS)
@Threads(1)
@Fork(value = 2, jvmArgsAppend = {"-Xms512m", "-Xmx512m", "-XX:+UseG1GC"})
@Warmup(iterations = 3, time = 1)
@Measurement(iterations = 5, time = 1)
public class SerializationBenchmark {
    @Param({"EMPTY", "TYPICAL", "HEAVY"})
    public SerializationFixtures.Profile profile;

    @Param({"JSON", "JAVA_BASE64", "JAVA_RAW"})
    public SerializationFixtures.Format format;

    private SerializationFixtures.Snapshot snapshot;
    private byte[][] encoded;

    @Setup
    public void prepare() throws Exception {
        snapshot = SerializationFixtures.create(profile);
        encoded = SerializationFixtures.encode(snapshot, format);
    }

    @Benchmark
    public byte[][] serialize() throws Exception {
        return SerializationFixtures.encode(snapshot, format);
    }

    @Benchmark
    public SerializationFixtures.Snapshot deserialize() throws Exception {
        return SerializationFixtures.decode(encoded, format);
    }

    public static void main(String[] args) throws Exception {
        Path reportDirectory = Path.of("build", "reports", "benchmarks");
        Files.createDirectories(reportDirectory);
        writeEnvironment(reportDirectory.resolve("serialization-environment.properties"));
        writePayloadSizes(reportDirectory.resolve("serialization-sizes.csv"));
        new Runner(new OptionsBuilder()
                .parent(new CommandLineOptions(args))
                .include(SerializationBenchmark.class.getName() + ".*")
                .shouldFailOnError(true)
                .addProfiler(GCProfiler.class)
                .resultFormat(ResultFormatType.JSON)
                .result(reportDirectory.resolve("serialization.json").toString())
                .build()).run();
    }

    private static void writeEnvironment(Path target) throws Exception {
        Properties properties = new Properties();
        for (String key : new String[]{"java.version", "java.vm.name", "java.vm.version", "os.name", "os.arch", "os.version"})
            properties.setProperty(key, System.getProperty(key));
        properties.setProperty("gson.source", Path.of(Gson.class.getProtectionDomain()
                .getCodeSource().getLocation().toURI()).getFileName().toString());
        try (var output = Files.newBufferedWriter(target)) {
            properties.store(output, "Serialization benchmark environment; see JMH JSON for fork flags");
        }
    }

    private static void writePayloadSizes(Path target) throws Exception {
        StringBuilder csv = new StringBuilder(
                "profile,format,QuestStatus,PlayerQuestCooldowns,DungeonBossLockouts,QuestLockouts,totalBytes\n");
        for (SerializationFixtures.Profile profile : SerializationFixtures.Profile.values()) {
            var snapshot = SerializationFixtures.create(profile);
            for (SerializationFixtures.Format format : SerializationFixtures.Format.values()) {
                byte[][] values = SerializationFixtures.encode(snapshot, format);
                csv.append(profile).append(',').append(format);
                for (byte[] value : values) csv.append(',').append(value.length);
                csv.append(',').append(Arrays.stream(values).mapToInt(value -> value.length).sum()).append('\n');
            }
        }
        Files.writeString(target, csv);
        System.out.println("Payload sizes: " + target);
    }
}
