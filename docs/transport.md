# Curved fast travel

EliteMobs owns boarding, destinations, instance policy and recovery. MagmaCore owns the sampled Catmull–Rom curve and native flying Mind controller. The carrier moves through native entity movement each tick; the player rides it. Player flight permissions are never changed. Teleports are used for disembarking and recovery.

This requires the native Mind adapter (currently Minecraft 26.x). Each passenger gets a separate temporary mount defined by an ordinary `custombosses` YAML file. Equipment, disguise, custom model, powers and AI use the same implementation as other bosses. The route controls flight, passengers and recovery.

## Author a route

Commands require `elitemobs.transport.admin` (operators have it). The editor does not grant creative flight: use your existing admin flight controls.

1. Stand on clear, solid ground at the boarding point: `/em transport create harbor_to_keep`.
2. Fly to a waypoint and run `/em transport add`. Repeat through the air corridor, ending on clear, solid landing ground. Use at least three points for a curved route; two points describe a straight trip.
3. White particles mark committed waypoints. Green is the committed curve; cyan previews the curve if you add your current position. Red means blocked clearance; yellow means terrain is not loaded. Preview is private and does not load terrain.
4. `/em transport move 2` moves waypoint 2 to your feet. `remove` removes the last point; `undo` restores a waypoint edit (up to 32 edits).
5. Face the desired arrival direction and run `/em transport save`. `cancel` discards the draft. `status` reports the draft's point count.
6. Return within eight blocks of the first waypoint and use `/em transport start harbor_to_keep`. Stand still during preparation/countdown. `ride` tests an unsaved draft from its boarding point. `/em transport stop` aborts your test flight and attempts to return you to where you boarded.

`/em transport edit <id>` loads an existing route. `list` lists saved routes; `reload` reloads YAML without changing active flights. Saving finishes the editor session. Drafts are discarded on disconnect. Unsaved `ride` tests do not save a route.

Leave generous room around corners: a spline can bend outside the polygon connecting its waypoints. The controller reduces speed for turns and brakes before the endpoint. Boarding validates the whole sampled curve and the landing, not only the waypoints. Saving validates geometry; it does not certify that unloaded terrain is safe.

## Route configuration

Save as `plugins/EliteMobs/transport_routes/harbor_to_keep.yml`. The filename is the unique route ID, including when files are organized into subdirectories. These coordinates illustrate the format; replace them with points in your map.

```yaml
isEnabled: true
name: "Keep flight"
world: "primis"
transportEntity: "transport_cannon_seat.yml" # An enabled ordinary customboss file.
speed: 12.0 # Maximum blocks per second; turns can be slower.
acceleration: 8.0 # Blocks per second squared, shared between turning and speed changes.
countdownTicks: 60
arrivalYaw: 90.0
waypoints:
  - "100.5,65.0,100.5"
  - "105.5,80.0,120.5"
  - "130.5,90.0,150.5"
  - "150.5,80.0,155.5"
  - "160.5,65.0,160.5"
```

Speed and acceleration accept 1–32. Countdown accepts 0–200 ticks. Routes have 2–256 points, consecutive points 0.05–2048 blocks apart, and a maximum summed waypoint distance of 16,384 blocks. Terrain budgets usually impose a smaller practical limit.

New editor routes reference `transport_cannon_seat.yml`, an ordinary generated boss file whose spawn script applies invisibility. To use a visible creature, create another ordinary customboss file and reference it instead. For example:

```yaml
isEnabled: true
entityType: PIG
name: "&6Guild Gryphon"
level: 1
ai: true
customModel: guild_gryphon
dropsEliteMobsLoot: false
dropsVanillaLoot: false
dropsRandomLoot: false
dropsSkillXP: false
powers: [] # Ordinary powers may supply animation or other presentation.
```

The configured entity needs `ai: true` and must not be frozen. Its physical body must fit the supported envelope: at most 1.3 blocks wide/deep and 1.4 blocks high. Boarding rejects larger bodies. Clearance reserves 1.3 blocks horizontally and 3.3 blocks vertically for mount and rider; visible model wings may extend farther, so the artist/admin must allow room for those too. Missing or disabled entity files, unavailable configured models, and missing LibsDisguises for an explicit disguise reject boarding. The journey temporarily makes the mount invulnerable and nonpersistent; it does not replace its equipment or power list.

Routes support normal `isEnabled` and `extends` behavior. The editor preserves existing comments and unrecognized fields when saving. Obsolete `carrier`, route-level `customModel` and `flightAnimation` fields are rejected with an explanatory console error. Existing definitions are never converted automatically; author the entity file and update the route explicitly.

## NPC destinations

Add these fields to a normal EliteMobs NPC near the route's boarding point:

```yaml
interactionType: TRANSPORT
transportRoutes:
  - harbor_to_keep
  - harbor_to_mines
```

Talking opens a destination menu (up to 54 routes). Selection rechecks proximity to the NPC and route departure. Ordinary players use the NPC; the route authoring/start commands remain administrative. Each route is one-way: author a separate return route if wanted. Existing NPC dialogue objectives still run through their normal interaction path.

## FMM cannon or prop script

FMM exposes `context.world:start_elitemobs_transport(context.player, routeId)`. It returns whether boarding preparation was accepted, not whether the flight finished. Put this in an FMM script and bind that script to the cannon prop using its existing script configuration:

```lua
return {
  api_version = 1,
  on_right_click = function(context)
    if context.player then
      context.world:start_elitemobs_transport(context.player, "harbor_to_keep")
    end
  end
}
```

When authoring a prop to use this call, remove its separate movement/flight-permission loop. Do not run both transport implementations on the same click. Cannon effects may stay in its script; movement, seating and recovery belong to EliteMobs. This implementation does not automatically convert existing cannon scripts or replace Primis wormholes.

Java integrations on the server thread can call `TransportModule.startRoute(player, routeId)` through EliteMobs. The FMM bridge resolves this API through EliteMobs' current classloader so a plugin reload does not retain an old module.

## Instances, interruptions and operations

- In an instanced dungeon, `world` names the original content package world. EliteMobs binds it to the player's current instance copy. Creating a route inside a dungeon writes the original name automatically. Every point must remain within that match's allowed region; spectators cannot board.
- Ordinary-world disconnects leave a journal that sends the player to the destination on login. Instance recovery can use the destination only while the player still belongs to that same live instance; otherwise it uses their recorded pre-instance return location. Missing worlds are never recreated. An unsafe or unavailable recovery destination falls back to the server's primary-world spawn.
- The journal is forced to disk before mounting and removed only after a successful return/arrival teleport. Keep `transport_journeys/` private runtime data; do not ship it in dungeon ZIPs. If another plugin blocks recovery, the journal remains for the next attempt. Keep the primary-world spawn safe.
- Leaving/destroying a match removes its transport mount and releases its chunk tickets. Obstruction or timeout aborts the ride; ordinary completion resets fall distance. Shutdown resolves online ordinary-world riders to their destination and retains journals when recovery cannot finish.
- During flight, normal dismounts, player teleports, interactions, attacks and projectiles are blocked; incoming player damage is cancelled. These protections end with the journey. Admins can use `transport stop` before teleporting a rider.
- At most 32 journeys run concurrently, with at most 128 chunks per route and 256 distinct route chunks held globally. Paper loads existing terrain asynchronously; Spigot loads one existing chunk per tick. Neither path generates missing terrain. Chunk tickets are shared and released after the last journey using them finishes.
- For dungeon packaging, place files under `transport_routes/<dungeonFolder>/`. `/em package` includes that directory, and the DLC importer recognizes `transport_routes`. FMM models and scripts still follow their normal packaging paths.

## Verification boundary

Compilation validates the Java/API integration. Real-client acceptance is still required for passenger smoothness, FMM passenger/animation alignment, tight bends, collision changes during flight, disconnect/reconnect, and match teardown. The cannon's ordinary spawn script applies invisibility after native body creation, so a brief visible spawn has not been ruled out. Test both the default invisible seat and a modeled mount before replacing a shipped dungeon's travel network.
