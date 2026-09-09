# Combat HUD live concept

Copy `mods` into `plugins/EliteMobs/resource_pack/`, then rebuild and send the
ResourcePackManager pack. This is an opt-in Java-client calibration pack, kept
separate from the exported defaults so the artist can replace its two textures.
It is not automatically exported by the plugin jar.

The wood/brass concept occupies exactly 190 by 54 GUI pixels. `gray.png` and
`red.png` retain their calibration filenames, but now contain the normal and
F-active artwork. The images are 190x54 with a font height of 54. A single bitmap glyph must fit Minecraft's 256x256 font atlas. The normal
hotbar aperture is transparent; the skill cards are opaque and cover item pixels.
`node generate.cjs` regenerates artwork, fill strips, text atlas, and the 33
offset fonts with `sharp`. `generate-calibration.py` retains the old half-opacity
rectangles in a separate `calibration` output folder.

The probe renders real health, class-resource amount, and vanilla XP progress.
Health/resource bars update from those same values. The skill cards select
class-specific placeholder artwork. Armor, hunger and conditional vital rows
are covered by this opt-in experiment; it is not a replacement production HUD.
Fonts are `elitemobs:combat_hud_concept_0` through `_32`; the default font is untouched.

Resource icons are a separate dynamic glyph at x=171, y=5, in a 10x15 cell.
The resource snapshot selects the root class's icon, including specializations:

| Root class | Resource | Icon | Icon glyph | Fill color |
| --- | --- | --- | --- | --- |
| Paladin | Resolve | Gold shield | U+E500 | Gold |
| Berserker | Fury | Red-orange flame | U+E501 | Orange-red |
| Ranger | Focus | Green feather | U+E502 | Green |
| Cleric | Grace | Ivory sunburst | U+E503 | Ivory-gold |
| Spellcaster | Mana | Blue crystal | U+E504 | Cyan-blue |

The 50x15 `resource_icons.png` atlas uses five 10x15 cells, each with an
11-pixel advance. Both backgrounds leave the icon area empty; a missing
resource snapshot shows no icon. The counter and bar retain their alignment.

Health and energy use four distinct liquid poses at five frames per second:
rolling highlights, pooling shadows and small bright pockets. Each pose uses
sixteen one-pixel columns. Energy samples the texture in reverse so its motion
mirrors health, and uses the current resource's palette. The XP strip and
diamond have rising glints instead of sideways motion. All effects stay inside
the current fill, anchored to the trough when amounts change. The diamond's
rim and empty area remain still, as do icons and counters. The existing
action-bar compositor sends frame changes without an additional scheduled task.

Strip glyphs occupy U+E800 through U+E9BF in 64-character groups: health,
Resolve, Fury, Focus, Grace, Mana, XP. Each group contains four sixteen-column
poses. The separate F badge atlas uses U+E520 through U+E527: four neutral
pulse frames, then four green active frames. Its 8x7 cells advance nine pixels.

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
Signature and Utility show a green F badge + a mouse pictogram with the left or right button
highlighted in amber. The inactive button stays gray; no LMB/RMB lettering is
needed. Mobility shows a green F followed by a white F, separated by an arrow.
Green indicates the first input has already been pressed; white is the next
input. The central badge switches to green for the selection window.

Cards appear in Signature, Utility, Mobility order, without printed slot names.
Each 60x21 card has its 13x13 ability image at x+3,y+4, input graphics at
x+22,y+2, and the resource icon and cost beneath them at y+12 and y+14.
The cost uses the casting calculation, including passive modifiers, rounded
up for display. Affordability uses the exact unrounded cost and the casting
controller's tolerance. Green numerals mean enough energy; red numerals and
a dark red card mean insufficient energy. This is an energy indicator, not
a promise that targeting or other activation requirements will succeed.
Unavailable cards replace only their own background before the icon and cost
are drawn. Their glyphs are U+E680..E682; green/red cost digits use U+E700..E709
and U+E710..E719. The five small resource icons use U+E540..E544.

The existing class badge projects four pixels above the panel, two pixels
higher than its previous position. Its baked lettering remains pending the
choice of a localizable font positioning mechanism.

The probe temporarily replaces EliteMobs' action-bar output for that player.
Turning it off restores ordinary messages. Logout, plugin shutdown and restart
discard the probe. It does not alter inventories, item packets, game mode, or
key bindings. Other plugins can still write to the same action-bar channel.

## Geometry and acceptance

The vanilla 26.2 client extracts the action bar after the hotbar on a new render
stratum. Its text origin is `(floor(guiWidth/2), guiHeight-72)`. Bitmap glyphs
start 7 pixels below that origin minus their configured ascent. With ascent -11,
the intended panel bounds are `[center-95, center+95)` horizontally and
`[guiHeight-54, guiHeight)` vertically. The bitmap's extra one-pixel advance is
cancelled with a negative space. Shadows are disabled on the component.

The 182-pixel hotbar sits four pixels from each side. Its 184-pixel selection
outline has a transparent aperture starting at x=3, y=31, including both outer
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
pixels. Rectangles use exclusive right and bottom edges. Health and resource
labels are omitted; icons, counters and bars identify the values. Removing the
label row reduces the main panel height by six GUI pixels while preserving
the native hotbar position. The separate label alphabet is no longer shipped.

| Element | X | Y | Width | Height |
| --- | ---: | ---: | ---: | ---: |
| Health card | 4 | 3 | 89 | 20 |
| Resource card | 97 | 3 | 89 | 20 |
| Health counter | 25 | 7 | up to 53 | 7 |
| Resource counter | 165 minus visible width | 7 | up to 53 | 7 |
| Health fill | 25 | 17 | up to 63 | 3 |
| Resource fill | 165 minus fill width | 17 | up to 63 | 3 |
| Resource icon | 171 | 5 | 10 | 15 |
| Cropped class XP diamond | 79 | -3 | 32 | 23 |
| Class level | centered at 95 | 3 | 5 per digit, 1 spacing | 7 |
| F badge | 91 | 22 | 8 | 7 |
| XP fill | 5 | 26 | up to 180 | 2 |
| Native hotbar opening | 3 | 31 | 184 | 23 |
| Signature card | 4 | 32 | 60 | 21 |
| Utility card | 65 | 32 | 60 | 21 |
| Mobility card | 126 | 32 | 60 | 21 |

Counters occupy rows 7 through 13, followed by two empty rows before the
trough at row 16.
Each fill is inset one pixel inside its trough. The resource card mirrors the
health card: icon on the right, trough at x=101, and fill within [102,165).
Resource counters end at x=165, excluding their trailing spacing
pixel. Resource fill grows leftward from that same right edge.
Skill icons start at card x+3, y=35; labels at x+19, y=35;
binding F badges at x+19, y=43. The 9x8 mouse icons start at x+35, y=42 and
end before row 50, inside the card interior. Skill frames end at row 52, reserving row 53 for the
outer panel and avoiding clipping when the framebuffer height is not an exact
multiple of the GUI scale.

The class diamond is cut horizontally seven pixels above its original midpoint,
removing the top nine rows. Its flat brass rim projects three pixels above the
panel's top border; the lower point and level number stay in place.
The remaining interior has 19 fill rows; the runtime's 29 progress
frames map proportionately onto those rows. Gold rises from the
bottom according to XP toward the active class's next effective level, using
the class band's XP baseline. At the current progression cap it stays full.
The white number shows effective class level, including specialization levels.
An absent or locked class hides the diamond. Instance-locked class selections
take precedence over the profile's selection. The 29 fill states share a
256x168 bitmap atlas per animation frame; the level is a separate glyph layer above the fill.
The compact F badge has a separate glyph below the diamond, rendered after
the dynamic XP strip so it cannot be painted over. It leaves two empty rows
before the hotbar at y=31 and follows the diamond's class visibility. It pulses
in gray while idle and in green while the F selection window is active.

The initial alignment revision was deployed and checked on NBTest on 2026-09-09.
Native F2 capture at 3840x2071, GUI scale 8, placed the panel at framebuffer
1160,1592. Pixel-color measurements matched that earlier 60-pixel layout exactly:
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

The class diamond revision was compiled and deployed to NBTest on 2026-09-09.
The Java client showed the live class at level 10 with a full capped fill,
clear of both counters and bars. All 29 atlas states were measured for
horizontal symmetry and successive bottom-up rows. Native screenshot level
bounds are [89,100) horizontally and [1,8) vertically. Evidence is retained at
`_triage/hud-class-diamond-20260909/normal-native.png`, `normal.png`,
`measurements.json`, and `server.log`. Live XP gain and rollover were not
exercised; the player's progression was preserved. The deployed jar SHA-256 is
`ce1f66f4a3670cc26fe9b78e236bbb41c06a593947d6b1c3d94499ae80154e5d`.

The compact revision removes the health/resource words and their font provider.
It was built and deployed to NBTest on 2026-09-09; server startup and resource
pack hosting completed. In-game inspection of this 54-pixel revision is pending.
Jar SHA-256: c61526fec35baf85ec5bf78575c94bedab23ea7a44e1f246417938846f7461a7.
