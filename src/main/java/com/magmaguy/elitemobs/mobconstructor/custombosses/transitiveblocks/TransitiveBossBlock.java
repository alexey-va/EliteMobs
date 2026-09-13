package com.magmaguy.elitemobs.mobconstructor.custombosses.transitiveblocks;

import com.magmaguy.elitemobs.api.EliteMobRemoveEvent;
import com.magmaguy.elitemobs.api.EliteMobSpawnEvent;
import com.magmaguy.elitemobs.api.internal.RemovalReason;
import com.magmaguy.elitemobs.mobconstructor.custombosses.RegionalBossEntity;
import com.magmaguy.magmacore.util.Logger;
import org.bukkit.Location;
import org.bukkit.Material;
import org.bukkit.block.BlockFace;
import org.bukkit.block.data.BlockData;
import org.bukkit.block.data.Directional;
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;

public class TransitiveBossBlock implements Listener {

    private static void setBlockData(TransitiveBlock transitiveBlock, Location spawnLocation) {
        if (spawnLocation == null || spawnLocation.getWorld() == null) return;
        double rotation = 0;

        BlockData blockData = transitiveBlock.getBlockData().clone();
        Location location = targetLocation(spawnLocation, transitiveBlock, rotation);
        if (rotation != 0) {
            if (blockData instanceof Directional)
                ((Directional) blockData).setFacing(rotateBlockFace(((Directional) blockData).getFacing(), rotation));
        }

        // Authored transitions may target a door several chunks away from the boss arena.
        // Reading or writing an unloaded target chunk silently leaves the transition unapplied.
        // Load the actual destination chunk; the old check only inspected the boss's chunk.
        int chunkX = location.getBlockX() >> 4;
        int chunkZ = location.getBlockZ() >> 4;
        if (!location.getWorld().isChunkLoaded(chunkX, chunkZ))
            location.getWorld().getChunkAt(chunkX, chunkZ);

        //Minor optimization, does not replace blocks that are already identical
        if (!location.getBlock().getBlockData().equals(blockData))
            location.getBlock().setBlockData(blockData, blockData.getMaterial() == Material.WATER || blockData.getMaterial() == Material.LAVA);

    }

    static Location targetLocation(Location spawnLocation, TransitiveBlock transitiveBlock, double rotation) {
        if (rotation == 0) return spawnLocation.clone().add(transitiveBlock.getRelativeLocation());
        return spawnLocation.clone().add(
                transitiveBlock.getRelativeLocation().clone().rotateAroundY(Math.toRadians(rotation)));
    }

    /*
    1 = north
    2 = east
    3 = south
    4 = west
     */
    private static int blockFaceToInt(BlockFace blockFace) {
        switch (blockFace) {
            case NORTH:
                return 1;
            case EAST:
                return 2;
            case SOUTH:
                return 3;
            case WEST:
                return 4;
            default:
                Logger.warn("Attempted to rotate a block through the transitive block system that does not have a north / south / east / west face. This is not currently supported.");
                return 1;
        }
    }

    private static BlockFace intToBlockFace(int blockFaceValue) {
        switch (blockFaceValue) {
            case 1:
                return BlockFace.NORTH;
            case 2:
                return BlockFace.EAST;
            case 3:
                return BlockFace.SOUTH;
            case 4:
                return BlockFace.WEST;
            default:
                Logger.warn("Attempted to rotate a block through the transitive block system that does not have a north / south / east / west face. This is not currently supported.");
                return BlockFace.NORTH;
        }
    }

    private static BlockFace rotateBlockFace(BlockFace blockFace, double rotation) {
        int adjustedRotation = (int) (rotation / 90d);
        int blockFaceInt = blockFaceToInt(blockFace);
        int result = blockFaceInt + adjustedRotation;
        if (result > 4) result -= 4;
        if (result < 1) result += 4;
        return intToBlockFace(result);
    }

    @EventHandler(ignoreCancelled = true)
    public void onBossSpawn(EliteMobSpawnEvent event) {
        if (!(event.getEliteMobEntity() instanceof RegionalBossEntity regionalBossEntity)) return;
        if (regionalBossEntity.getOnSpawnTransitiveBlocks() != null && !regionalBossEntity.getOnSpawnTransitiveBlocks().isEmpty())
            for (TransitiveBlock transitiveBlock : regionalBossEntity.getOnSpawnTransitiveBlocks())
                setBlockData(transitiveBlock, regionalBossEntity.getSpawnLocation());
    }

    @EventHandler(ignoreCancelled = true)
    public void onBossRemove(EliteMobRemoveEvent event) {
        if (!(event.getEliteMobEntity() instanceof RegionalBossEntity regionalBossEntity)) return;
        // Only apply the on-remove blocks when the boss is actually DEFEATED. EliteMobRemoveEvent
        // also fires for SHUTDOWN/reload, BOSS_TIMEOUT, ARENA_RESET and admin removal (see
        // CustomBossEntity.remove); applying the "cleared" block state on those meant a server
        // restart (or despawn) would save the world with the boss's structure wrongly cleared
        // even though it was never killed, and it would then rebuild via onSpawn on the next
        // spawn — the "order of clearing on boss deaths" bug. Death/kill are the only genuine
        // defeats, so the clearing must be gated to them.
        RemovalReason reason = event.getRemovalReason();
        if (reason != RemovalReason.DEATH && reason != RemovalReason.KILL_COMMAND) return;
        if (regionalBossEntity.getOnRemoveTransitiveBlocks() != null && !regionalBossEntity.getOnRemoveTransitiveBlocks().isEmpty())
            for (TransitiveBlock transitiveBlock : regionalBossEntity.getOnRemoveTransitiveBlocks())
                setBlockData(transitiveBlock, regionalBossEntity.getSpawnLocation());
    }
}
