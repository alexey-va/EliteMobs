# Combat HUD rectangle experiment

Copy `mods` into `plugins/EliteMobs/resource_pack/`, then rebuild and send the
ResourcePackManager pack. This is an opt-in Java-client calibration pack, kept
separate from the exported defaults so the artist can replace its two textures.
It is not automatically exported by the plugin jar.

Both textures are exactly 190 by 60 pixels at 50% opacity (alpha 128/255).
Gray is RGB 128,128,128; red is RGB 220,40,40.
`python generate.py` regenerates the PNGs and font JSON.
The font is `elitemobs:combat_hud_probe`; no default Minecraft font is replaced.

```
/em hudprobe show magmaguy 0 0
/em hudprobe show magmaguy 0 -2
/em hudprobe off magmaguy
```

The coordinates are offsets in GUI pixels. Positive x moves right and positive
y moves down. Accepted ranges are x=-64..64 and y=-16..16. They apply identically
to both colors. A class must be active and its skill controls enabled; pressing
F makes the panel red for the actual ability-selection window, then gray again.
The existing F,F, F+LMB and F+RMB bindings keep working.

The probe temporarily replaces EliteMobs' action-bar output for that player.
Turning it off restores ordinary messages. Logout, plugin shutdown and restart
discard the probe. It does not alter inventories, item packets, game mode, or
key bindings. Other plugins can still write to the same action-bar channel.

## Geometry and acceptance

The vanilla 26.2 client extracts the action bar after the hotbar on a new render
stratum. Its text origin is `(floor(guiWidth/2), guiHeight-72)`. Bitmap glyphs
start 7 pixels below that origin minus their configured ascent. With ascent -5,
the intended panel bounds are `[center-95, center+95)` horizontally and
`[guiHeight-60, guiHeight)` vertically. The bitmap's extra one-pixel advance is
cancelled with a negative space. Shadows are disabled on the component.

The 182-pixel hotbar fits with four pixels of margin on each side. The height
also covers the usual XP, health, hunger and armor rows, with extra room above.
Extra health/absorption rows and the offhand slot can extend outside this area.
Minecraft GUI scale multiplies the panel and vanilla HUD together. Text
background settings, client mods or shaders can affect the final appearance.

Client screenshot calibration remains necessary: confirm the lower edge,
horizontal centering, translucent coverage over item icons, and identical placement
in gray and red. Record any offsets chosen for the artist. Do not treat server
startup or pack delivery as visual acceptance. Inventory hiding is outside
this experiment; none is needed to establish whether the glyph covers items.
