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

Sources are retained locally under sources/. Final 64x64 textures and the prompt manifest are versioned. Initial root artwork generated before the size correction retains its original prompt; its full-resolution source was downsampled to 64x64. The HUD footprint remains 190x54 GUI pixels. Each icon occupies a 13x13 GUI-pixel square inside a 15x15 frame.

All 155 unique built-in abilities have artwork: 150 Signature/Utility abilities and five shared root Mobility abilities. The immutable Java glyph map is generated alongside the font providers. Effective class lineage uses the same snapshot as skill activation, including instance-locked classes.

The separate Goblin transport correction passed its authorized Paper 26.2 Autotester fixture and is included in this build. That fixture does not establish coverage of every authored Goblin cannon route.
