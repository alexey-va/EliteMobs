# Ability artwork

- [x] Export all 155 unique ability IDs and gameplay descriptions from the built-in catalog. Movement is shared by each root tree.
- [x] Deploy the preceding liquid animation, class colors and green F badge revision to NBTest.
- [ ] Generate one ImageGen asset per ability. Keep the complete prompt and provenance in manifest.json.
- [ ] Inspect every texture at 64x64 and its actual 13x13 HUD size. Revise unreadable subjects.
- [x] Replace the rectangular placeholders with square slots inside the existing cards. Retain Signature, Utility, Mobility ordering.
- [x] Render the current effective abilities dynamically, including the inherited movement skill.
- [ ] Compile, inspect all generated font mappings, deploy to NBTest and verify pack delivery.

Sources are retained locally under sources/. The final 64x64 textures and prompt manifest are versioned. The full HUD footprint remains 190x54 GUI pixels. The icon slot is square; texture resolution does not enlarge the HUD.

Goblin fast travel remains with the explicitly assigned Autotester agent. Deploy its fix only after its separate runtime verification.

Current checkpoint: all 15 root icons generated, reviewed in the card preview, and compiled with the new dynamic renderer. Specialization artwork remains in progress; manifest.json records generated/reviewed state. The icon build has not yet been deployed. The preceding HUD animation and the separately verified transport fix are deployed to NBTest.
