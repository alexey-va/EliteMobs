const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const directory = path.join(__dirname,'ability-art');
const roots = ['paladin','berserker','ranger','cleric','spellcaster'];
(async () => {
 const layers=[];
 const cards=await sharp(path.join(__dirname,'mods/assets/elitemobs/textures/gui/combat_hud_probe/red.png'))
  .extract({left:0,top:32,width:190,height:22}).resize(760,88,{kernel:'nearest'}).toBuffer();
 for(const [row,root] of roots.entries()) {
  const top=row*114+20;
  layers.push({input:cards,left:0,top});
  for(const [index,slot] of ['signature','utility','mobility'].entries()) {
   const source=path.join(directory,`${root}.${slot}.png`);
   layers.push({input:await sharp(source).resize(52,52,{kernel:'nearest'}).toBuffer(),left:(7+index*61)*4,top:top+16});
  }
  layers.push({input:Buffer.from(`<svg width="760" height="18"><text x="4" y="14" font-size="14" fill="white">${root} | 32x32 textures in 13x13 GUI slots at scale 4</text></svg>`),left:0,top:row*114});
 }
 fs.mkdirSync(path.join(directory,'previews'),{recursive:true});
 await sharp({create:{width:760,height:roots.length*114,channels:4,background:'#15181c'}}).composite(layers)
  .png().toFile(path.join(directory,'previews/hud-roots.png'));
})();
