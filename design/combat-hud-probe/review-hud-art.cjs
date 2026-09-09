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
   const costs=[40,25,20], affordable=costs[index]<=30;
   const assets=path.join(__dirname,'mods/assets/elitemobs/textures/gui/combat_hud_probe');
   if(!affordable) layers.push({input:await sharp(path.join(assets,`skill_unaffordable_${index}.png`))
    .resize(240,84,{kernel:'nearest'}).toBuffer(),left:(4+index*61)*4,top});
   const source=path.join(__dirname,'mods/assets/elitemobs/textures/gui/combat_hud_probe/abilities',`${root}.${slot}.png`);
   layers.push({input:await sharp(source).resize(52,52,{kernel:'nearest'}).toBuffer(),left:(7+index*61)*4,top:top+16});
   const digits=String(costs[index]), start=4+index*61+38-Math.floor((digits.length*4+7)/2);
   layers.push({input:await sharp(path.join(assets,'resource_icons.png')).extract({left:row*10,top:0,width:10,height:15})
    .resize(19,28,{kernel:'nearest'}).toBuffer(),left:start*4,top:top+48});
   for(const [i,digit] of [...digits].entries()) layers.push({input:await sharp(path.join(assets,`cost_${affordable?'ready':'unaffordable'}.png`))
    .extract({left:Number(digit)*3,top:0,width:3,height:5}).resize(12,20,{kernel:'nearest'}).toBuffer(),left:(start+8+i*4)*4,top:top+56});
  }
  layers.push({input:Buffer.from(`<svg width="760" height="18"><text x="4" y="14" font-size="14" fill="white">${root} | 32x32 textures in 13x13 GUI slots at scale 4</text></svg>`),left:0,top:row*114});
 }
 fs.mkdirSync(path.join(directory,'previews'),{recursive:true});
 await sharp({create:{width:760,height:roots.length*114,channels:4,background:'#15181c'}}).composite(layers)
  .png().toFile(path.join(directory,'previews/hud-roots.png'));
})();
