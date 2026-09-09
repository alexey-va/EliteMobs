// Pixel-grid implementation of the approved wood/brass concept. No inventory packets.
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const root = path.join(__dirname, 'mods/assets/elitemobs');
const textures = path.join(root, 'textures/gui/combat_hud_probe');
const fonts = path.join(root, 'font');
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
 ',':['000','000','000','010','100'],
};
const rect=(x,y,w,h,c)=>`<rect x="${x}" y="${y}" width="${w}" height="${h}" fill="${c}"/>`;
const poly=(p,c)=>`<polygon points="${p}" fill="${c}"/>`;
const svg=(w,h,body)=>`<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}" shape-rendering="crispEdges">${body}</svg>`;
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
function frame(x,y,w,h,active=false){return rect(x,y,w,h,'#181611')+rect(x,y,w,1,active?'#f6d07b':'#9d8154')+rect(x,y,1,h,active?'#d9ae5b':'#79613e')+rect(x+1,y+1,w-2,h-2,'#4b3725')+rect(x+2,y+2,w-4,h-4,'#121b20')+rect(x+2,y+2,w-4,1,'#263237')+rect(x+1,y+h-2,w-2,1,'#2d241c');}
function heart(x,y){return `<g transform="translate(${x} ${y})">`+poly('0,2 2,0 4,0 6,2 8,0 10,0 12,2 12,6 6,12 0,6','#681f28')+poly('1,2 2,1 4,1 6,3 8,1 10,1 11,2 11,5 6,10 1,5','#ec364c')+rect(2,2,2,3,'#ff8c95')+rect(8,2,2,1,'#ff6575')+`</g>`;}
function crystal(x,y){return `<g transform="translate(${x} ${y})">`+poly('5,0 10,5 10,11 5,15 0,11 0,5','#074854')+poly('5,1 9,5 9,10 5,13 1,10 1,5','#12bed7')+poly('5,1 5,13 2,9 2,5','#78eeef')+poly('6,3 8,5 8,9 6,11','#0086b9')+rect(4,3,1,7,'#c0ffff')+`</g>`;}
function icon(kind,x,y){let s=rect(x,y,13,15,'#080e13')+rect(x+1,y+1,11,13,'#203239');
 if(kind===0) s+=poly(`${x+8},${y+3} ${x+11},${y+3} ${x+10},${y+10} ${x+5},${y+12} ${x+3},${y+11} ${x+8},${y+7}`,'#b58a4e')+poly(`${x+2},${y+2} ${x+8},${y+5} ${x+6},${y+6} ${x+1},${y+4}`,'#d5faff')+poly(`${x+1},${y+6} ${x+7},${y+7} ${x+5},${y+9} ${x+2},${y+8}`,'#81b4c2');
 if(kind===1) s+=poly(`${x+8},${y+2} ${x+11},${y+4} ${x+7},${y+8} ${x+8},${y+8} ${x+2},${y+13} ${x+5},${y+7} ${x+3},${y+7}`,'#009ddd')+poly(`${x+8},${y+3} ${x+9},${y+4} ${x+5},${y+9} ${x+6},${y+6}`,'#b5ffff');
 if(kind===2) s+=poly(`${x+6},${y+2} ${x+11},${y+7} ${x+6},${y+12} ${x+1},${y+7}`,'#047a95')+poly(`${x+6},${y+3} ${x+10},${y+7} ${x+6},${y+11} ${x+2},${y+7}`,'#3dc9e4')+poly(`${x+6},${y+5} ${x+8},${y+7} ${x+6},${y+9} ${x+4},${y+7}`,'#091b24')+rect(x+6,y+1,1,13,'#a7ffff')+rect(x+1,y+7,11,1,'#a7ffff');
 return s;}
function panel(active){
 let s=rect(0,0,190,60,'#211c17')+rect(1,1,188,58,'#503925');
 for(let y=2;y<60;y+=3) for(let x=2;x<188;x+=13) s+=rect(x,y,5+((x*7+y)%7),1,(x+y)%2?'#62472d':'#352a20');
 s+=rect(0,0,190,1,active?'#ffe099':'#b08e5d')+rect(0,0,1,60,'#957244')+rect(189,0,1,60,'#171712');
 s+=frame(4,3,89,26,active)+frame(97,3,89,26,active)+heart(8,11)+crystal(171,9);
 for(const x of [24,101]) s+=rect(x,22,65,5,'#080c0f')+rect(x+1,23,63,3,x<90?'#471c26':'#073e4b');
 s+=rect(4,30,182,6,'#17191a')+rect(4,30,182,1,'#806944')+rect(5,32,180,2,'#183123')+rect(5,35,180,1,'#392d21');
 if(active){
  const cards=[{name:'SIGNATURE',key:'F + LMB',icon:1},{name:'UTILITY',key:'F + RMB',icon:2},{name:'MOBILITY',key:'F , F',icon:0}];
  cards.forEach((card,i)=>{const x=4+i*61;s+=frame(x,38,60,21,true)+icon(card.icon,x+3,41)+smallText(card.name,x+19,41,'#eee4cb')+smallText(card.key,x+19,50,'#add9e4');});
 } else {
  // The whole vanilla hotbar remains visible, including item counts and selected-slot border.
  s+=`<rect x="3" y="37" width="184" height="23" fill="black"/>`;
 }
 for(const x of [1,187]) for(const y of [2,56]) s+=rect(x,y,2,2,active?'#f4cb79':'#be9b62')+rect(x,y,1,1,'#ffebac');
 return s;
}
(async()=>{
 // One 32x32 glyph per fill height, packed below the 256px atlas limit.
 // Two-pixel stepped brass rim; the interior has 28 rows filled bottom-up.
 let diamonds='';
 for(let fill=0;fill<=28;fill++) {
  for(let yy=0;yy<32;yy++) for(let xx=0;xx<32;xx++) {
   const distance=Math.abs(xx-15.5)+Math.abs(yy-15.5);
   if(distance>16) continue;
   let color=distance>15?'#241a12':distance>14?(yy<16?'#edcc82':'#927044'):'#172128';
   if(distance<=14 && yy>=30-fill) color=yy===30-fill?'#f5d476':'#916b24';
   diamonds+=rect((fill%8)*32+xx,Math.floor(fill/8)*32+yy,1,1,color);
  }
 }
 await sharp(Buffer.from(svg(256,128,diamonds))).png().toFile(path.join(textures,'class_diamond.png'));
 await sharp(Buffer.from(svg(60,16,text('0123456789',0,0,'#ffffff')))).png().toFile(path.join(textures,'class_level.png'));
 for(const [name,active] of [['gray',false],['red',true]]){
  let body=panel(active);
  if(!active)body=`<defs><mask id="m">${rect(0,0,190,60,'white')}${rect(3,37,184,23,'black')}</mask></defs><g mask="url(#m)">${body}</g>`;
  fs.writeFileSync(path.join(__dirname,`${name}.svg`),svg(190,60,body));
  await sharp(Buffer.from(svg(190,60,body))).png().toFile(path.join(textures,name+'.png'));
 }
 const alphabet='0123456789/ABCDEFGHIJKLMNOPQRSTUVWXYZ';
 await sharp(Buffer.from(svg(alphabet.length*6,7,text(alphabet,0,0,'#ffffff')))).png().toFile(path.join(textures,'text.png'));
 // Five visible rows plus two transparent rows: no fractional resampling, and
 // enough provider height for the full supported ascent range.
 let labels='';
 [...alphabet].forEach((c,i)=>{if(smallGlyphs[c]) labels+=smallText(c,i*4,0,'#ffffff');});
 for(const name of ['HEALTH','ENERGY','MANA','RESOLVE','GRACE','FOCUS','FURY'])
  for(const c of name) if(!smallGlyphs[c]) throw new Error(`Missing resource label glyph ${c}`);
 await sharp(Buffer.from(svg(alphabet.length*4,7,labels))).png().toFile(path.join(textures,'labels.png'));
 for(const [name,color,h] of [['health','#ed3f57',3],['resource','#16cbe4',3],['xp','#74b941',2]])
  await sharp(Buffer.from(svg(1,h,rect(0,0,1,h,color)))).png().toFile(path.join(textures,name+'.png'));
 for(let y=-16;y<=16;y++){
  const bitmap=(file,height,ascent,chars)=>{
   if(ascent-y>height) throw new Error(`Invalid ascent for ${file} at offset ${y}`);
   return {type:'bitmap',file:`elitemobs:gui/combat_hud_probe/${file}.png`,height,ascent:ascent-y,chars:[chars]};
  };
  const providers=[{type:'space',advances:{'\ue100':1,'\ue101':-1}},
    bitmap('gray',60,-5,'\ue000'),bitmap('red',60,-5,'\ue001'),
    bitmap('text',7,-18,alphabet),bitmap('labels',7,-11,[...alphabet].map((c,i)=>String.fromCodePoint(0xe200+i)).join('')),
    bitmap('health',3,-28,'\ue110'),bitmap('resource',3,-28,'\ue111'),bitmap('xp',2,-37,'\ue112')];
  providers.push(bitmap('class_level',16,-6,Array.from({length:10},(_,i)=>String.fromCodePoint(0xe300+i)).join('')));
  const diamond=bitmap('class_diamond',32,7,'');
  diamond.chars=Array.from({length:4},(_,row)=>Array.from({length:8},(_,col)=>{
   const index=row*8+col; return index<=28?String.fromCodePoint(0xe400+index):'\u0000';
  }).join(''));
  providers.push(diamond);
  fs.writeFileSync(path.join(fonts,`combat_hud_concept_${y+16}.json`),JSON.stringify({providers},null,2)+'\n');
 }
 console.log('Generated live HUD concept textures and 33 offset fonts.');
})();
