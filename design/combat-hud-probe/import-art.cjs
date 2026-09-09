const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const [id, source] = process.argv.slice(2);
const directory = path.join(__dirname, 'ability-art');
const manifestPath = path.join(directory, 'manifest.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath));
const entry = manifest.find(item => item.id === id);
if (!entry || !source) throw new Error('Expected known ability ID and generated image path');
(async () => {
  const original = path.join(directory, 'sources', `${id}.png`);
  fs.mkdirSync(path.dirname(original), {recursive: true});
  if (path.resolve(source) !== original) fs.copyFileSync(source, original);
  await sharp(original).resize(64, 64, {fit: 'cover', kernel: 'lanczos3'})
    .flatten({background: '#081a20'}).png().toFile(path.join(directory, `${id}.png`));
  entry.generation = 'built-in ImageGen';
  entry.status = 'generated-awaiting-visual-review';
  entry.source = `sources/${id}.png`;
  entry.texture = `${id}.png`;
  fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2) + '\n');
  console.log(`Imported ${id}: 64x64`);
})();
