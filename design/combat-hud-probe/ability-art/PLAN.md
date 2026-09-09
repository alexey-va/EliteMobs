# Ability artwork

- [x] Export all 155 unique ability IDs and gameplay descriptions from the built-in catalog. Movement is shared by each root tree.
- [x] Deploy the preceding liquid animation, class colors and green F badge revision to NBTest.
- [x] Generate one ImageGen asset per ability. Keep prompts and provenance in manifest.json.
- [x] Inspect every texture at 64x64 and at 13 GUI pixels with GUI scales 1 and 4. Revise unreadable or excessively similar subjects.
- [x] Replace rectangular placeholders with square slots inside the existing cards. Retain Signature, Utility, Mobility ordering.
- [x] Render the current effective abilities dynamically, including inherited movement skills.
- [x] Compile and validate all 155 catalog mappings, texture sizes, copied pack assets and all 33 font variants.
- [x] Deploy the matching jar and assets to NBTest with a backup and restart.
- [x] Verify the reloaded resource pack is served with all 155 icons. Public pack byte checks passed for 155 textures and 33 font files; startup log had no error or exception lines.
- [ ] Inspect the icons in a live Minecraft client when computer control is available.

Sources are retained locally under sources/. Final 32x32 textures and the prompt manifest are versioned. Initial root artwork generated before the size correction retains its original prompt; its full-resolution source was downsampled to 32x32. The HUD footprint remains 190x54 GUI pixels. Each icon occupies a 13x13 GUI-pixel square inside a 15x15 frame.

All 155 unique built-in abilities have artwork: 150 Signature/Utility abilities and five shared root Mobility abilities. The immutable Java glyph map is generated alongside the font providers. Effective class lineage uses the same snapshot as skill activation, including instance-locked classes.

The separate Goblin transport correction passed its authorized Paper 26.2 Autotester fixture and is included in this build. That fixture does not establish coverage of every authored Goblin cannon route.

Current comparison revision: all 155 textures were reduced directly from their retained ImageGen originals to 32x32 using Lanczos3. HUD geometry and glyph mappings are unchanged. The five root card rows were visually inspected at GUI scale 4. All 155 served PNG dimensions and exact bytes were verified after an RSPM reload on NBTest. No server restart was needed.

Every exported ability icon now carries a centered PLACE / HOLDER label. The generator applies the shared pixel lettering when exporting the pack, preserving the unmarked artwork and original sources. Card previews read the actual exported textures.

Placeholder lettering now spans up to 29x22 texture pixels, with a one-pixel dark outline and 72% opacity. There is no background panel. The original images remain unmarked.

Class badge and feedback layout:
- The active form uses one of 75 generated badges. Badge bounds are x=4..77, y=-2..6 relative to the panel, leaving the heart at y=7 clear. Its glyph advances 75 pixels and is compensated like the other overlays.
- The winning transient source is rendered above the panel using Minecraft's normal glyph shapes. Persistent HUD text and the redundant gesture-controls message stay out of this line.
- Feedback overlays have zero net horizontal advance, including bold and half-pixel Unicode advances. Font definitions and metrics are derived together by prepare-feedback-font.py from the matching client jar and unifont assets. Vanilla bitmap and Unicode providers are used explicitly so the client's Force Unicode preference cannot change the measured widths. The feedback line stays at the native action-bar vertical position; normal calibration is x=0, y=0.
- Default reading-based lifetimes double while the HUD probe is active, with a six-second minimum and a 30-second maximum. Explicit producer lifetimes and source priorities remain unchanged.
- Build and generated asset validation passed. NBTest received the matching jar and pack, restarted without error lines, and its public pack matched all 75 badge images and 34 font definitions. Live client visual validation remains pending because native computer control is unavailable. The player was offline at the final enable attempt.
