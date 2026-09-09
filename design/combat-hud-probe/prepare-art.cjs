const fs = require('fs');
const path = require('path');
const directory = path.join(__dirname, 'ability-art');
const palette = {
  paladin: 'ivory and warm gold, muted steel',
  berserker: 'burnt orange and crimson, dark iron',
  ranger: 'leaf green and amber, leather brown',
  cleric: 'luminous ivory and pale gold, lavender shadows',
  spellcaster: 'electric blue and violet, cyan highlights'
};
const catalog = JSON.parse(fs.readFileSync(path.join(directory, 'catalog.json')));
const previous = fs.existsSync(path.join(directory, 'manifest.json'))
  ? JSON.parse(fs.readFileSync(path.join(directory, 'manifest.json'))) : [];
const manifest = catalog.map(ability => ({...ability,
  prompt: `Use case: stylized-concept. Create ONE square fantasy RPG ability icon for ${ability.className}'s '${ability.name}'. Actual gameplay effect: ${ability.description} Depict that effect with one unmistakable dominant subject or symbol and at most one supporting effect. Choose the subject based on the actual gameplay effect, especially for summons. Art for an actual game HUD: will be downsampled to 64x64 and displayed at 13x13 GUI pixels. Polished hand-painted fantasy game spell icon with broad clean color masses, bold silhouette and thick dark separations. Close composition, subject occupies 85 percent of the square. Palette: ${palette[ability.root]}; adapt accent colors to the actual ability element where needed. Opaque dark midnight-teal background, strong local contrast. Keep subject recognizable at tiny size; simplify aggressively, do not paint an entire battle scene. No text, letters, numbers, border, frame, watermark, fine ornamentation or small scattered particles. Square composition.`,
  ...previous.find(item => item.id === ability.id)
}));
fs.writeFileSync(path.join(directory, 'manifest.json'), JSON.stringify(manifest, null, 2) + '\n');
