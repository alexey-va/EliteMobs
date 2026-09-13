package com.magmaguy.elitemobs.mobconstructor.custombosses.transitiveblocks;

import org.bukkit.Location;
import org.bukkit.Material;
import org.bukkit.util.Vector;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockbukkit.mockbukkit.MockBukkit;

import static org.junit.jupiter.api.Assertions.assertEquals;

class TransitiveBossBlockTest {
    @BeforeEach
    void open() {
        MockBukkit.mock();
    }

    @AfterEach
    void close() {
        MockBukkit.unmock();
    }

    @Test
    void distantDoorUsesItsOwnTargetChunk() {
        var world = MockBukkit.getMock().addSimpleWorld("mines");
        var spawn = new Location(world, 100.5, 80, 100.5);
        var door = new TransitiveBlock(Material.AIR.createBlockData(), new Vector(-49.5, -29, -131.5));

        Location target = TransitiveBossBlock.targetLocation(spawn, door, 0);

        assertEquals(51, target.getBlockX());
        assertEquals(51, target.getBlockY());
        assertEquals(-31, target.getBlockZ());
        assertEquals(3, target.getBlockX() >> 4);
        assertEquals(-2, target.getBlockZ() >> 4);
    }
}
