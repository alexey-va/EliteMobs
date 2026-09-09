# Combat HUD live concept

Copy `mods` into `plugins/EliteMobs/resource_pack/`, then rebuild and send the
ResourcePackManager pack. This is an opt-in Java-client calibration pack, kept
separate from the exported defaults so the artist can replace its two textures.
It is not automatically exported by the plugin jar.

The wood/brass concept occupies exactly 190 by 60 GUI pixels. `gray.png` and
`red.png` retain their calibration filenames, but now contain the normal and
F-active artwork. The images are 190x60 with a font height of 60. A single bitmap glyph must fit Minecraft's 256x256 font atlas. The normal
hotbar aperture is transparent; the skill cards are opaque and cover item pixels.
`node generate.cjs` regenerates artwork, fill strips, text atlas, and the 33
offset fonts with `sharp`. `generate-calibration.py` retains the old half-opacity
rectangles in a separate `calibration` output folder.

The probe renders real health, class-resource name/amount, and vanilla XP progress.
Health/resource bars update from those same values. Skill labels/icons are a
visual concept, not class-specific art. Armor, hunger and conditional vital rows
are covered by this opt-in experiment; it is not a replacement production HUD.
Fonts are `elitemobs:combat_hud_concept_0` through `_32`; the default font is untouched.

```
/em hudprobe show magmaguy 0 0
/em hudprobe show magmaguy 0 -2
/em hudprobe off magmaguy
```

The coordinates are offsets in GUI pixels. Positive x moves right and positive
y moves down. Accepted ranges are x=-64..64 and y=-16..16. They apply identically
to both colors. A class must be active and its skill controls enabled; pressing
F shows the three skill cards for the actual ability-selection window, then the hotbar again.
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
horizontal centering, opaque skill-card coverage over item icons, and identical placement
in the normal and skill states. Record any offsets chosen for the artist. Do not treat server
startup or pack delivery as visual acceptance. Inventory hiding is outside
this experiment; none is needed to establish whether the glyph covers items.

The concept was checked in the Java 26.2 client on NBTest on 2026-09-09 with
offsets `0 0`, in both a small window and the maximized window. The normal hotbar
and selected-slot border fit the aperture. Pressing F showed all three labeled
cards in the same bounds, then restored the hotbar. Resolve values and bar width
increased together during passive regeneration. Final captures are retained in
the workspace at `_triage/hud-concept-20260909/normal.png` and `active.png`.
The final pack loaded without font errors. Bedrock has not been checked.
