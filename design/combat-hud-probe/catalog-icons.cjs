// Export the authored ability catalog for artwork production, preserving stable IDs.
const fs = require('fs');
const path = require('path');
const source = fs.readFileSync(path.join(__dirname, '../../src/main/java/com/magmaguy/elitemobs/experimentalcombat/content/BuiltInClassDefinitions.java'), 'utf8');
const target = path.join(__dirname, 'ability-art');
fs.mkdirSync(target, {recursive: true});
const entries = [];
let root;
for (const match of source.matchAll(/\b(root|form)\((?:"(?:[^"\\]|\\.)*"|[^)"])*\)/g)) {
  const strings = [...match[0].matchAll(/"((?:[^"\\]|\\.)*)"/g)].map(m => JSON.parse('"' + m[1] + '"'));
  if (!strings.length) continue;
  const isRoot = match[1] === 'root';
  const [id, className] = strings;
  if (isRoot) root = id;
  const slots = isRoot ? ['mobility', 'signature', 'utility'] : ['signature', 'utility'];
  const start = isRoot ? 2 : 3;
  slots.forEach((slot, i) => entries.push({id: `${id}.${slot}`, root, className, slot,
    name: strings[start + i * 2], description: strings[start + i * 2 + 1]}));
}
if (entries.length !== 155 || new Set(entries.map(e => e.id)).size !== 155)
  throw new Error(`Unexpected ability catalog: ${entries.length}`);
fs.writeFileSync(path.join(target, 'catalog.json'), JSON.stringify(entries, null, 2) + '\n');
console.log(`Exported ${entries.length} unique abilities, including five shared movement abilities.`);
