// Contact sheet: native texture plus the 13-GUI-pixel slot at GUI scales 4 and 1.
// Sample the texture directly at physical resolution; Minecraft does not first shrink it to 13px.
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const directory = path.join(__dirname, 'ability-art');
const ids = process.argv.slice(2);
const manifest = JSON.parse(fs.readFileSync(path.join(directory, 'manifest.json')));
const entries = manifest.filter(e => e.texture && (!ids.length || ids.includes(e.id)));
const escape = value => value.replace(/&/g, '&amp;').replace(/</g, '&lt;');
(async () => {
  const layers = [];
  for (const [i, entry] of entries.entries()) {
    const source = path.join(directory, entry.texture);
    layers.push({input: await sharp(source).resize(128,128,{kernel:'nearest'}).toBuffer(), left: 4, top:i*150+18});
    const small = await sharp(source).resize(13,13,{kernel:'nearest'}).toBuffer();
    layers.push({input: await sharp(source).resize(52,52,{kernel:'nearest'}).toBuffer(), left:150, top:i*150+50});
    layers.push({input: small,left:270,top:i*150+70});
    layers.push({input: Buffer.from(`<svg width="320" height="18"><text x="4" y="13" fill="white" font-size="12">${escape(entry.id)}</text></svg>`),left:0,top:i*150});
  }
  fs.mkdirSync(path.join(directory, 'previews'), {recursive:true});
  await sharp({create:{width:320,height:entries.length*150,channels:4,background:'#171b20'}})
    .composite(layers).png().toFile(path.join(directory,'previews/review.png'));
})();
