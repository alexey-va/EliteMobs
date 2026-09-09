// Pixel-grid implementation of the approved wood/brass concept. No inventory packets.
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const root = path.join(__dirname, 'mods/assets/elitemobs');
const textures = path.join(root, 'textures/gui/combat_hud_probe');
const fonts = path.join(root, 'font');
const abilityDirectory = path.join(__dirname, 'ability-art');
const abilityManifest = JSON.parse(fs.readFileSync(path.join(abilityDirectory, 'manifest.json')));
const abilityIcons = abilityManifest.map((entry,index) => ({...entry, glyph: 0xea00 + index}))
 .filter(entry => entry.texture);
fs.mkdirSync(textures, {recursive:true}); fs.mkdirSync(fonts, {recursive:true});
const glyphs = {
 '+':['00000','00100','00100','11111','00100','00100','00000'],
 ',':['00000','00000','00000','00000','00110','00100','01000'],
 '0':['01110','10001','10011','10101','11001','10001','01110'],
 '1':['00100','01100','00100','00100','00100','00100','11111'],
 '2':['01110','10001','00001','00010','00100','01000','11111'],
 '3':['11110','00001','00001','01110','00001','00001','11110'],
 '4':['00010','00110','01010','10010','11111','00010','00010'],
 '5':['11111','10000','10000','11110','00001','00001','11110'],
 '6':['01110','10000','10000','11110','10001','10001','01110'],
 '7':['11111','00001','00010','00100','01000','01000','01000'],
 '8':['01110','10001','10001','01110','10001','10001','01110'],
 '9':['01110','10001','10001','01111','00001','00001','01110'],
 '/':['00001','00001','00010','00100','01000','10000','10000'],
 'A':['01110','10001','10001','11111','10001','10001','10001'],
 'B':['11110','10001','10001','11110','10001','10001','11110'],
 'C':['01111','10000','10000','10000','10000','10000','01111'],
 'D':['11110','10001','10001','10001','10001','10001','11110'],
 'E':['11111','10000','10000','11110','10000','10000','11111'],
 'F':['11111','10000','10000','11110','10000','10000','10000'],
 'G':['01111','10000','10000','10111','10001','10001','01111'],
 'H':['10001','10001','10001','11111','10001','10001','10001'],
 'I':['11111','00100','00100','00100','00100','00100','11111'],
 'J':['00111','00010','00010','00010','10010','10010','01100'],
 'K':['10001','10010','10100','11000','10100','10010','10001'],
 'L':['10000','10000','10000','10000','10000','10000','11111'],
 'M':['10001','11011','10101','10101','10001','10001','10001'],
 'N':['10001','11001','10101','10011','10001','10001','10001'],
 'O':['01110','10001','10001','10001','10001','10001','01110'],
 'P':['11110','10001','10001','11110','10000','10000','10000'],
 'Q':['01110','10001','10001','10001','10101','10010','01101'],
 'R':['11110','10001','10001','11110','10100','10010','10001'],
 'S':['01111','10000','10000','01110','00001','00001','11110'],
 'T':['11111','00100','00100','00100','00100','00100','00100'],
 'U':['10001','10001','10001','10001','10001','10001','01110'],
 'V':['10001','10001','10001','10001','10001','01010','00100'],
 'W':['10001','10001','10001','10101','10101','10101','01010'],
 'X':['10001','10001','01010','00100','01010','10001','10001'],
 'Y':['10001','10001','01010','00100','00100','00100','00100'],
 'Z':['11111','00001','00010','00100','01000','10000','11111'],
};
// Whole-pixel 3x5 lettering for the narrow skill cards. Fractional scaling drops strokes.
const smallGlyphs = {
 A:['010','101','111','101','101'], B:['110','101','110','101','110'],
 C:['111','100','100','100','111'], H:['101','101','111','101','101'],
 E:['111','100','110','100','111'], F:['111','100','110','100','100'],
 G:['111','100','101','101','111'], I:['111','010','010','010','111'],
 L:['100','100','100','100','111'], M:['101','111','111','101','101'],
 N:['101','111','111','111','101'], O:['111','101','101','101','111'],
 R:['110','101','110','101','101'], S:['111','100','111','001','111'],
 T:['111','010','010','010','010'], U:['101','101','101','101','111'],
 Y:['101','101','010','010','010'], '+':['000','010','111','010','000'],
 V:['101','101','101','101','010'],
 J:['001','001','001','101','111'], K:['101','101','110','101','101'],
 Q:['111','101','101','111','001'], W:['101','101','111','111','101'],
 X:['101','101','010','101','101'], Z:['111','001','010','100','111'],
 P:['110','101','110','100','100'], D:['110','101','101','101','110'],
 ',':['000','000','000','010','100'],
};
const rect=(x,y,w,h,c)=>`<rect x="${x}" y="${y}" width="${w}" height="${h}" fill="${c}"/>`;
const poly=(p,c)=>`<polygon points="${p}" fill="${c}"/>`;
const svg=(w,h,body)=>`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" shape-rendering="crispEdges">${body}</svg>`;
function shade(base,brightness) {
 return '#'+[1,3,5].map(i=>Math.max(0,Math.min(255,
  Math.round(parseInt(base.slice(i,i+2),16)*brightness))).toString(16).padStart(2,'0')).join('');
}
// Four distinct liquid poses: a crest rolls down, pools, rebounds and breaks
// into small bright pockets. These are not translated copies of one wave.
const liquidPoses=[
 ['1122221100000011','0011122100011100','0000111000112100'],
 ['0011222110000111','0011232100112100','0001121100122100'],
 ['0000111122221100','0012211100132210','0011100000011100'],
 ['1111000011222310','1122110000111100','0012211000000100']
];
function stripColor(base,x,y,phase,xp=false) {
 if(!xp) return shade(base,[0.72,0.94,1.12,1.38][Number(liquidPoses[phase][y][x])]);
 // XP glints rise from the lower row, then fade, rather than running sideways.
 const beat=(phase+Math.floor(x/4))%4;
 const glint=x%4===2 && ((beat===0&&y===1)||(beat===1&&y===0));
 return shade(base,glint?1.45:y===0?1.08:0.8);
}
function experienceColor(x,y,phase,fillStart) {
 let color=y===fillStart?'#d8b760':shade('#967024',0.87+(30-y)*0.008);
 // Staggered rising bubbles, clipped by the real fill and diamond silhouette.
 for(const [bx,by] of [[7,17],[16,24],[24,15]]) {
  const bubbleY=by+((6-phase*2)%8);
  const distance=Math.abs(x-bx)+Math.abs(y-bubbleY);
  if(distance===0) color='#f2d990';
  else if(distance===1) color='#bd974e';
 }
 return color;
}
function keyBadge(x,y,active,phase=1) {
 const body=active?['#38864f','#439b58','#52b366','#439b58'][phase]
  :['#c6cecf','#dbe1df','#eef2ed','#dbe1df'][phase];
 let s=rect(x+1,y,6,7,active?'#9beca3':'#f8faf9')
  +rect(x,y+1,8,5,active?'#9beca3':'#f8faf9')+rect(x+1,y+1,6,5,body);
 ['1111','1000','1110','1000','1000'].forEach((row,yy)=>[...row].forEach((v,xx)=>{
  if(v==='1') s+=rect(x+2+xx,y+1+yy,1,1,active?'#f0fff2':'#435158');
 }));
 return s;
}
function text(t,x,y,color,scale=1) {
 let s=''; for(const c of t.toUpperCase()) {
  if(glyphs[c]) glyphs[c].forEach((r,yy)=>[...r].forEach((v,xx)=>{if(v==='1')s+=rect(x+xx*scale,y+yy*scale,scale,scale,color)}));
  x+=6*scale;
 } return s;
}
function smallText(t,x,y,color) {
 let s=''; for(const c of t) {
  if(c!==' ' && !smallGlyphs[c]) throw new Error(`Missing skill-card glyph: ${c}`);
  smallGlyphs[c]?.forEach((row,yy)=>[...row].forEach((v,xx)=>{if(v==='1')s+=rect(x+xx,y+yy,1,1,color)}));
  x+=4;
 } return s;
}
// Four-pixel-wide lettering fits HOLDER plus its outline inside a 32px icon.
function placeholderStamp() {
 const letters = {
  P:['1110','1001','1001','1110','1000','1000','1000'],
  L:['1000','1000','1000','1000','1000','1000','1111'],
  A:['0110','1001','1001','1111','1001','1001','1001'],
  C:['0111','1000','1000','1000','1000','1000','0111'],
  E:['1111','1000','1000','1110','1000','1000','1111'],
  H:['1001','1001','1001','1111','1001','1001','1001'],
  O:['0110','1001','1001','1001','1001','1001','0110'],
  D:['1110','1001','1001','1001','1001','1001','1110'],
  R:['1110','1001','1001','1110','1010','1001','1001']
 };
 const ink = new Set();
 for(const [word,y] of [['PLACE',5],['HOLDER',18]]) {
  const x = Math.floor((32-(word.length*5-1))/2);
  [...word].forEach((letter,i)=>{
   for(let row=0;row<9;row++) [...letters[letter][Math.floor(row*7/9)]].forEach((v,col)=>{
    if(v==='1') ink.add(`${x+i*5+col},${y+row}`);
   });
  });
 }
 const outline = new Set();
 for(const point of ink) {
  const [x,y]=point.split(',').map(Number);
  for(let dy=-1;dy<=1;dy++) for(let dx=-1;dx<=1;dx++) {
   const neighbor=`${x+dx},${y+dy}`;
   if(!ink.has(neighbor)) outline.add(neighbor);
  }
 }
 const pixels=(points,color)=>[...points].map(p=>{const [x,y]=p.split(',').map(Number);return rect(x,y,1,1,color);}).join('');
 return svg(32,32,`<g opacity="0.72">${pixels(outline,'#090d12')}${pixels(ink,'#fff0ac')}</g>`);
}
function mouseButton(button,x,y) {
 const colors={o:'#899599',b:'#38444b',c:'#dce4e4',
  L:button==='left'?'#ffc36b':'#4e5b62',R:button==='right'?'#ffc36b':'#4e5b62'};
 const rows=['...ooooo...','..oLLcRRo..','.oLLLcRRRo.','oLLLLcRRRRo','oLLLLcRRRRo',
  'ooooooooooo','obbbbbbbbbo','obbbbbbbbbo','.obbbbbbbo.','..ooooooo..'];
 let s='';
 rows.forEach((row,yy)=>[...row].forEach((pixel,xx)=>{
  if(pixel!=='.') s+=rect(x+xx,y+yy,1,1,colors[pixel]);
 }));
 return s;
}
function skillBinding(binding,x,y) {
 const badge=(bx,pressed)=>rect(bx+1,y,8,9,pressed?'#9beca3':'#f8faf9')
  +rect(bx,y+1,10,7,pressed?'#9beca3':'#f8faf9')
  +rect(bx+1,y+1,8,7,pressed?'#439b58':'#dbe1df')
  +smallText('F',bx+3,y+2,pressed?'#f0fff2':'#435158');
 const first=badge(x,true);
 if(binding==='double-f') return first+poly(`${x+13},${y+2} ${x+16},${y+4} ${x+13},${y+6}`,'#add9e4')
  +badge(x+20,false);
 return first+smallText('+',x+13,y+2,'#add9e4')+mouseButton(binding,x+20,y);
}
function frame(x,y,w,h,active=false){return rect(x,y,w,h,'#181611')+rect(x,y,w,1,active?'#f6d07b':'#9d8154')+rect(x,y,1,h,active?'#d9ae5b':'#79613e')+rect(x+1,y+1,w-2,h-2,'#4b3725')+rect(x+2,y+2,w-4,h-4,'#121b20')+rect(x+2,y+2,w-4,1,'#263237')+rect(x+1,y+h-2,w-2,1,'#2d241c');}
function heart(x,y){return `<g transform="translate(${x} ${y})">`+poly('0,2 2,0 4,0 6,2 8,0 10,0 12,2 12,6 6,12 0,6','#681f28')+poly('1,2 2,1 4,1 6,3 8,1 10,1 11,2 11,5 6,10 1,5','#ec364c')+rect(2,2,2,3,'#ff8c95')+rect(8,2,2,1,'#ff6575')+`</g>`;}
function crystal(x,y){return `<g transform="translate(${x} ${y})">`+poly('5,0 10,5 10,11 5,15 0,11 0,5','#074854')+poly('5,1 9,5 9,10 5,13 1,10 1,5','#12bed7')+poly('5,1 5,13 2,9 2,5','#78eeef')+poly('6,3 8,5 8,9 6,11','#0086b9')+rect(4,3,1,7,'#c0ffff')+`</g>`;}
// Order is the explicit U+E500..E504 contract in CombatHud.resourceIcon.
const resourceTypes=['resolve','fury','focus','grace','mana'];
function resourceIcon(type,x,y) {
 if(type==='mana') return crystal(x,y);
 let s='';
 switch(type) {
  case 'resolve':
   s=poly('0,1 5,0 10,1 10,8 8,11 5,15 2,11 0,8','#69471c')
    +poly('1,2 5,1 9,2 9,8 7,11 5,13 3,11 1,8','#eab953')
    +poly('2,3 5,2 8,3 8,8 5,12 2,8','#956921')
    +rect(4,3,2,7,'#fff0ac')+rect(2,5,6,2,'#fff0ac')+rect(1,2,1,5,'#fff1b4');
   break;
  case 'fury':
   s=poly('5,0 8,4 7,6 9,5 10,9 9,12 7,14 3,15 0,12 0,8 2,4 2,8 4,6','#75232a')
    +poly('5,2 7,5 6,8 8,7 9,10 8,12 6,14 3,14 1,11 1,9 3,6 3,10 5,7','#ec4b30')
    +poly('5,7 7,10 7,12 5,14 3,13 2,11 4,9 4,11','#ffad3c')
    +poly('5,10 6,12 5,14 4,12','#fff1a0');
   break;
  case 'focus':
   s=poly('7,0 10,1 10,6 8,9 5,11 3,11 1,15 0,14 2,10 2,6 4,2','#164936')
    +poly('7,1 9,2 9,6 7,8 4,10 3,9 3,6 5,3','#5bb765')
    +poly('7,2 8,2 7,5 5,7 3,10 3,7 5,4','#afe297')
    +poly('8,2 9,3 5,9 1,15 0,14 4,8','#e2e8bc')
    +rect(6,6,3,1,'#215f43')+rect(4,9,3,1,'#215f43');
   break;
  case 'grace':
   s=rect(4,0,2,15,'#a5803f')+rect(0,6,10,3,'#a5803f')
    +poly('1,3 3,3 9,11 7,12','#a5803f')+poly('7,3 9,3 3,12 1,11','#a5803f')
    +poly('5,2 7,5 10,7 7,10 5,13 3,10 0,7 3,5','#eed69a')
    +poly('5,4 7,7 5,11 3,7','#fff9e0')
    +rect(4,5,2,5,'#ffffff')+rect(2,6,6,2,'#ffffff');
   break;
  default: throw new Error(`Unknown resource icon: ${type}`);
 }
 return `<g transform="translate(${x} ${y})">${s}</g>`;
}
function iconSlot(x,y){return rect(x,y,15,15,'#080e13')+rect(x+1,y+1,13,13,'#203239');}
const bindings=['left','right','double-f'];
function skillCard(index,x,y,unaffordable=false) {
 return frame(x,y,60,21,true)
  +(unaffordable?rect(x+2,y+2,56,17,'#401e25')+rect(x+2,y+2,56,1,'#69333b'):'')
  +iconSlot(x+2,y+3)+skillBinding(bindings[index],x+22,y+2);
}
function panel(active){
 let s=rect(0,0,190,54,'#211c17')+rect(1,1,188,52,'#503925');
 for(let y=2;y<54;y+=3) for(let x=2;x<188;x+=13) s+=rect(x,y,5+((x*7+y)%7),1,(x+y)%2?'#62472d':'#352a20');
 s+=rect(0,0,190,1,active?'#ffe099':'#b08e5d')+rect(0,0,1,54,'#957244')+rect(189,0,1,54,'#171712');
 s+=frame(4,3,89,20,active)+frame(97,3,89,20,active)+heart(8,7);
 for(const x of [24,101]) s+=rect(x,16,65,5,'#080c0f')+rect(x+1,17,63,3,x<90?'#471c26':'#18272b');
 s+=rect(4,24,182,6,'#17191a')+rect(4,24,182,1,'#806944')+rect(5,26,180,2,'#183123')+rect(5,29,180,1,'#392d21');
 if(active){
  bindings.forEach((_,i)=>s+=skillCard(i,4+i*61,32));
 } else {
  // The whole vanilla hotbar remains visible, including item counts and selected-slot border.
  s+=`<rect x="3" y="31" width="184" height="23" fill="black"/>`;
 }
 for(const x of [1,187]) for(const y of [2,50]) s+=rect(x,y,2,2,active?'#f4cb79':'#be9b62')+rect(x,y,1,1,'#ffebac');
 return s;
}
(async()=>{
 for(let i=0;i<3;i++) await sharp(Buffer.from(svg(60,21,skillCard(i,0,0,true))))
  .png().toFile(path.join(textures,`skill_unaffordable_${i}.png`));
 const numerals=['111101101101111','010110010010111','111001111100111','111001111001111',
  '101101111001001','111100111001111','111100111101111','111001001001001','111101111101111','111101111001111'];
 for(const [name,color] of [['ready','#8ee99b'],['unaffordable','#ff8c92']]) {
  let pixels='';
  numerals.forEach((rows,i)=>[...rows].forEach((bit,p)=>{if(bit==='1') pixels+=rect(i*3+p%3,Math.floor(p/3),1,1,color);}));
  await sharp(Buffer.from(svg(30,5,pixels))).png().toFile(path.join(textures,`cost_${name}.png`));
 }
 fs.mkdirSync(path.join(textures, 'abilities'), {recursive:true});
 // Full vanilla accents need more headroom than the old five-pixel alphabet.
 // Grow upward; keep the lower edge at y=6, above the heart and vitals.
 const badgeFrame=await sharp(Buffer.from(svg(74,14,frame(0,0,74,14,true)))).png().toBuffer();
 for(const [name,left,width] of [['left',0,3],['middle',3,1],['right',71,3]])
  await sharp(badgeFrame).extract({left,top:0,width,height:14}).png()
   .toFile(path.join(textures,`class_badge_${name}.png`));
 // Stamp every exported ability with the same legible UI label, preserving source art.
 const placeholderLabel = await sharp(Buffer.from(placeholderStamp())).png().toBuffer();
 for (const entry of abilityIcons) {
  const source = path.join(abilityDirectory, entry.texture);
  const metadata = await sharp(source).metadata();
  if (metadata.width !== 32 || metadata.height !== 32) throw new Error(`Ability must be 32x32: ${entry.id}`);
  await sharp(source).composite([{input:placeholderLabel}]).png()
   .toFile(path.join(textures, 'abilities', `${entry.id}.png`));
 }
 fs.writeFileSync(path.join(__dirname, '../../src/main/resources/combat-hud-ability-icons.properties'),
  '# Generated by design/combat-hud-probe/generate.cjs\n' + abilityIcons.map(e => `${e.id}=${e.glyph.toString(16)}`).join('\n') + '\n');
 await sharp(Buffer.from(svg(50,15,resourceTypes.map((type,i)=>resourceIcon(type,i*10,0)).join(''))))
  .png().toFile(path.join(textures,'resource_icons.png'));
 // Keep the diamond's existing 32x42 cells and origin; the animated F badge
 // now has its own glyph so its active color does not duplicate every XP pose.
 // Crop at row 9 so the rim projects three pixels above the panel. Preserve
 // the glyph origin and remap the runtime's 29 progress frames onto 19 fill rows.
 const diamondCut=9, fillTop=diamondCut+2, fillBottom=30;
 for(let frame=0;frame<4;frame++) {
 let diamonds='';
 for(let fill=0;fill<=28;fill++) {
  const ox=(fill%8)*32, oy=Math.floor(fill/8)*42;
  const fillStart=fillBottom-Math.round(fill/28*(fillBottom-fillTop));
  for(let yy=diamondCut;yy<32;yy++) for(let xx=0;xx<32;xx++) {
   const distance=Math.abs(xx-15.5)+Math.abs(yy-15.5);
   if(distance>16) continue;
   let color=distance>15?'#241a12':distance>14?(yy<16?'#edcc82':'#927044'):'#172128';
   if(yy===diamondCut) color='#241a12';
   else if(yy===diamondCut+1 && distance<=15) color='#edcc82';
   else if(distance<=14 && yy>=fillStart)
    color=experienceColor(xx,yy,frame,fillStart);
   diamonds+=rect(ox+xx,oy+yy,1,1,color);
  }
 }
 await sharp(Buffer.from(svg(256,168,diamonds))).png()
  .toFile(path.join(textures,frame===0?'class_diamond.png':`class_diamond_${frame}.png`));
 }
 await sharp(Buffer.from(svg(64,7,Array.from({length:8},(_,i)=>keyBadge(i*8,0,i>=4,i%4)).join(''))))
  .png().toFile(path.join(textures,'f_badges.png'));
 await sharp(Buffer.from(svg(60,16,text('0123456789',0,0,'#ffffff')))).png().toFile(path.join(textures,'class_level.png'));
 for(const [name,active] of [['gray',false],['red',true]]){
  let body=panel(active);
  if(!active)body=`<defs><mask id="m">${rect(0,0,190,54,'white')}${rect(3,31,184,23,'black')}</mask></defs><g mask="url(#m)">${body}</g>`;
  fs.writeFileSync(path.join(__dirname,`${name}.svg`),svg(190,54,body));
  await sharp(Buffer.from(svg(190,54,body))).png().toFile(path.join(textures,name+'.png'));
 }
 const alphabet='0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ';
 await sharp(Buffer.from(svg(alphabet.length*6,7,text(alphabet,0,0,'#ffffff')))).png().toFile(path.join(textures,'text.png'));
 // Four poses of sixteen one-pixel columns; runtime mirrors energy sampling.
 const strips=[['health','#ed3f57',3],['resource_resolve','#dcad4b',3],
  ['resource_fury','#ee6235',3],['resource_focus','#5bb765',3],
  ['resource_grace','#e7d7a4',3],['resource','#16cbe4',3],['xp','#74b941',2]];
 for(const pose of liquidPoses) for(const row of pose)
  if(row.length!==16) throw new Error('Liquid pose must contain sixteen columns');
 for(const [name,color,h] of strips) {
  let strip='';
  for(let phase=0;phase<4;phase++) for(let x=0;x<16;x++) for(let y=0;y<h;y++)
   strip+=rect(phase*16+x,y,1,1,stripColor(color,x,y,phase,name==='xp'));
  await sharp(Buffer.from(svg(64,h,strip))).png().toFile(path.join(textures,name+'.png'));
 }
 for(let y=-16;y<=16;y++){
  const bitmap=(file,height,ascent,chars)=>{
   if(ascent-y>height) throw new Error(`Invalid ascent for ${file} at offset ${y}`);
   return {type:'bitmap',file:`elitemobs:gui/combat_hud_probe/${file}.png`,height,ascent:ascent-y,chars:[chars]};
  };
  const chars=(base,length)=>Array.from({length},(_,i)=>String.fromCodePoint(base+i)).join('');
  const providers=[{type:'space',advances:{'\ue100':1,'\ue101':-1,'\ue102':-0.5,'\ue103':0.5}},
    bitmap('gray',54,-11,'\ue000'),bitmap('red',54,-11,'\ue001'),
    bitmap('text',7,-18,alphabet),bitmap('f_badges',7,-33,chars(0xe520,8))];
  strips.forEach(([name,,height],i)=>providers.push(bitmap(name,height,name==='xp'?-37:-28,chars(0xe800+i*64,64))));
  providers.push(bitmap('class_level',16,-14,Array.from({length:10},(_,i)=>String.fromCodePoint(0xe300+i)).join('')));
  providers.push(bitmap('resource_icons',15,-16,resourceTypes.map((_,i)=>String.fromCodePoint(0xe500+i)).join('')));
  providers.push(bitmap('resource_icons',7,-55,chars(0xe540,5)));
  providers.push(bitmap('cost_ready',5,-57,chars(0xe700,10)),bitmap('cost_unaffordable',5,-57,chars(0xe710,10)));
  bindings.forEach((_,i)=>providers.push(bitmap(`skill_unaffordable_${i}`,21,-43,String.fromCodePoint(0xe680+i))));
  ['left','middle','right'].forEach((name,i)=>providers.push(
   bitmap(`class_badge_${name}`,14,-4,String.fromCodePoint(0xe600+i))));
  for (const entry of abilityIcons)
   providers.push(bitmap(`abilities/${entry.id}`,13,-47,String.fromCodePoint(entry.glyph)));
  for(let frame=0;frame<4;frame++) {
  const diamond=bitmap(frame===0?'class_diamond':`class_diamond_${frame}`,42,1,'');
  diamond.chars=Array.from({length:4},(_,row)=>Array.from({length:8},(_,col)=>{
   const index=row*8+col; return index<=28?String.fromCodePoint(0xe400+frame*32+index):'\u0000';
  }).join(''));
  providers.push(diamond);
  }
  fs.writeFileSync(path.join(fonts,`combat_hud_concept_${y+16}.json`),JSON.stringify({providers},null,2)+'\n');
 }
 console.log('Generated live HUD concept textures and 33 offset fonts.');
})();
