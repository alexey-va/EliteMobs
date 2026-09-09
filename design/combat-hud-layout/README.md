# HUD drawing references

`01-outline-190x60.png` is a transparent tracing layer. Open at 100% in a pixel
editor and draw on a separate layer. One image pixel equals one Minecraft GUI
pixel. The SVG version has the same bounds and named geometry.

`01-outline-guide.png` is the labeled reference sheet. `01-outline-context.svg`
includes areas beyond the current panel. `01-outline-on-capture.png` places the
measured outlines directly over the live Minecraft screenshot.

The origin is the gray/red panel's top left, at `(floor(guiWidth/2)-95,
guiHeight-60)`. Both panel colors use the same geometry. `geometry.json` lists
every rectangle. The normal action-bar text starts 12 GUI pixels ABOVE the
panel. Its width follows the actual message, so it is not a fixed-width widget.
The observed HP/Mana ink occupies `(32,-12,125,7)` relative to the panel.

The live Minecraft 26.2 capture was taken on NBTest with the current resource
pack on 2026-09-09 at 02:38. Its framebuffer is 3840x2131, GUI scale is 8, and
the logical canvas is 480x267. The panel begins at physical `(1160,1656)`.
Rounding the logical canvas up clips five physical pixels at the bottom of this
window. The template retains the complete logical 60-pixel height.

Armor, hearts, hunger, XP background, nine item areas, hotbar and HP/Mana text
were visible in the capture and aligned against the 26.2 client layout. Dashed
offhand, air, XP-level and selected-item-name reserves are conditional layout
references. XP-level and text reserves have illustrative widths. Extra hearts,
absorption, regeneration bobbing, damage shaking and riding can extend or move
the vital rows. Offhand extends outside the 190-pixel panel.

`02-combat-hud-concept.png` is a separate visual exploration generated with the
built-in image generator. It illustrates a wood/brass frame, persistent health
and resource information, and three F-layer skill cards. It is not a calibrated
sprite sheet. Use the outline for final dimensions. The current 600 ms F window
is appropriate for a quick binding cue, not for reading long ability descriptions.
No inventory contents are modified by this design work. A pixel-grid adaptation
of the concept is implemented by `../combat-hud-probe/generate.cjs` for the opt-in
live HUD, with real health/resource values and a transparent normal hotbar aperture.

Regenerate the SVG/PNG outlines with `node generate.cjs` and the `sharp` package.
The full-frame output also needs the retained input at
`../../../_triage/hud-layout-20260909/vanilla-live.png`.
