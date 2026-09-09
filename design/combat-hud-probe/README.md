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

The 182-pixel hotbar sits four pixels from each side. Its 184-pixel selection
outline has a transparent aperture starting at x=3, y=37, including both outer
edges when the first or last slot is selected. The height
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

### Alignment grid

All coordinates below are relative to the panel's top-left corner, in GUI
pixels. Rectangles use exclusive right and bottom edges. The font uses whole
pixels throughout, with no fractional scaling.

| Element | X | Y | Width | Height |
| --- | ---: | ---: | ---: | ---: |
| Health card | 4 | 3 | 89 | 26 |
| Resource card | 97 | 3 | 89 | 26 |
| Health label | 25 | 6 | 23 | 5 |
| Resource label | 165 minus visible width | 6 | up to 27 | 5 |
| Health counter | 25 | 13 | up to 53 | 7 |
| Resource counter | 165 minus visible width | 13 | up to 53 | 7 |
| Health fill | 25 | 23 | up to 63 | 3 |
| Resource fill | 165 minus fill width | 23 | up to 63 | 3 |
| Resource icon | 171 | 9 | 10 | 15 |
| XP fill | 5 | 32 | up to 180 | 2 |
| Native hotbar opening | 3 | 37 | 184 | 23 |
| Mobility card | 4 | 38 | 60 | 21 |
| Signature card | 65 | 38 | 60 | 21 |
| Utility card | 126 | 38 | 60 | 21 |

Labels occupy rows 6 through 10, followed by two empty rows. Counters occupy
rows 13 through 19, followed by two empty rows before the trough at row 22.
Each fill is inset one pixel inside its trough. The resource card mirrors the
health card: icon on the right, trough at x=101, and fill within [102,165).
Resource labels and counters end at x=165, excluding their trailing spacing
pixel. Resource fill grows leftward from that same right edge.
Skill icons start at card x+3, y=41; labels at x+19, y=41;
bindings at x+19, y=50. Skill frames end at row 58, reserving row 59 for the
outer panel and avoiding clipping when the framebuffer height is not an exact
multiple of the GUI scale.

The initial alignment revision was deployed and checked on NBTest on 2026-09-09.
Native F2 capture at 3840x2071, GUI scale 8, placed the panel at framebuffer
1160,1592. Pixel-color measurements matched the coordinates above exactly:
label rows 6..10, counter rows 13..19, fills 23..25, skill labels 41..45,
and bindings 50..54. Both end-slot selection outlines were inspected in the
real client. The F capture shows all three cards with their bottom borders
inside the panel. Evidence is retained at
`_triage/hud-alignment-20260909/active-native.png`, `normal.png`,
`first-slot.png`, `last-slot.png`, and `measurements.json` in the workspace.
That revision's jar SHA-256 was
`d3b92d389b05382b9825bcba2be8bdc058d3df124016de5047b1ac780fc39d4a`.

The mirrored resource revision was compiled, deployed and checked in the same
client on NBTest on 2026-09-09. Native screenshot measurements place the resource
label, counter and fill at the same exclusive right edge, x=165. The crystal
sits to their right at x=171. Live regeneration grew the fill leftwards while
the text kept its right edge. Evidence is retained at
`_triage/hud-energy-right-20260909/normal-native.png`, `normal.png`,
`measurements.json`, and `server.log` in the workspace.
The deployed jar SHA-256 is
`d3d1b183d48a1bacf956f324e2812bd00e0679f5cec3cadaf1ddfa0d7cb2cf11`.
