// Deterministic tracing geometry. Run with the bundled Node runtime and sharp.
const fs = require('fs');
const path = require('path');
const sharp = require('sharp');
const out = __dirname;
const capture = path.resolve(out, '../../../_triage/hud-layout-20260909/vanilla-live.png');
const zones = [
  ['Panel',0,0,190,60,'#eef2f6'],
  ['Action text band',0,-12,190,9,'#c894ff','conditional'],
  ['Observed text ink',32,-12,125,7,'#c894ff','observed'],
  ['Item name',0,1,190,9,'#f5b774','conditional'],
  ['Armor',4,11,81,9,'#71b7ff'],
  ['Air',105,1,81,9,'#71b7ff','conditional'],
  ['Hearts',4,21,81,9,'#ff658a'],
  ['Hunger',105,21,81,9,'#ffca70'],
  ['XP bar',4,31,182,5,'#b4e978'],
  ['XP level reserve',82,25,26,9,'#b4e978','conditional'],
  ['Hotbar',4,38,182,22,'#54e3d2'],
  ['Selected slot 1',3,37,24,23,'#ffffff','conditional'],
  ['Offhand left',-25,37,29,24,'#999fb1','conditional'],
  ['Offhand right',186,37,29,24,'#999fb1','conditional'],
];
for(let i=0;i<9;i++) zones.push([`Item ${i+1}`,7+20*i,41,16,16,'#54e3d2']);
function rect(z,labels=false) {
  const [name,x,y,w,h,c,kind]=z;
  return `<g><title>${name}: ${x},${y} ${w}x${h}</title><rect x="${x+.5}" y="${y+.5}" width="${w-1}" height="${h-1}" fill="none" stroke="${c}" stroke-width="1"${kind==='conditional'?' stroke-dasharray="2 1"':''}/>${labels && !['Panel','Hotbar','Observed text ink','Selected slot 1'].includes(name)?`<text x="${x+w/2}" y="${y+h/2+1}" text-anchor="middle" fill="${c}" font-family="monospace" font-size="${name.startsWith('Item ')?3:3.2}">${name.startsWith('Item ') && name!=='Item name'?name.slice(5):name}</text>`:''}</g>`;
}
function svg(w,h,body) {return `<svg xmlns="http://www.w3.org/2000/svg" width="${w}" height="${h}" viewBox="0 0 ${w} ${h}">${body}</svg>`;}
function lines(w,h,step=1) { let a='';for(let x=0;x<=w;x+=step)a+=`<path d="M${x} 0V${h}"/>`;for(let y=0;y<=h;y+=step)a+=`<path d="M0 ${y}H${w}"/>`;return `<g stroke="#fff" stroke-opacity=".06" stroke-width=".15">${a}</g>`; }
async function save(name,xml,scale=1){fs.writeFileSync(path.join(out,name+'.svg'),xml);await sharp(Buffer.from(xml)).resize({width:Math.round(Number(xml.match(/width="([\d.]+)"/)[1])*scale),kernel:'nearest'}).png().toFile(path.join(out,name+'.png'));}
(async()=>{
  const core=zones.filter(z=>z[1]>=0&&z[2]>=0&&z[1]+z[3]<=190&&z[2]+z[4]<=60);
  await save('01-outline-190x60',svg(190,60,core.map(z=>rect(z)).join('')));
  await save('01-outline-context',svg(256,88,`<rect width="256" height="88" fill="#111720"/>${lines(256,88)}<g transform="translate(33 24)">${zones.map(z=>rect(z,true)).join('')}</g><path d="M128 0V88" stroke="#fff" stroke-opacity=".3" stroke-width=".3" stroke-dasharray="1 2"/>`),5);
  const header=`<rect width="1280" height="860" fill="#111720"/><text x="48" y="51" fill="#fff" font-family="Arial" font-size="27">Minecraft 26.2 / HUD tracing guide</text><text x="48" y="80" fill="#9baec3" font-family="Arial" font-size="15">GUI pixels. Origin (0,0) is the gray panel's top left. Panel is 190 x 60. Dashed zones are conditional.</text>`;
  const chart=`<g transform="translate(128 120) scale(4)">${lines(256,88)}<g transform="translate(33 24)">${zones.map(z=>rect(z,true)).join('')}</g></g>`;
  const entries=[['Hearts','4,21 / 81 x 9'],['Armor','4,11 / 81 x 9'],['Hunger','105,21 / 81 x 9'],['XP bar','4,31 / 182 x 5'],['Hotbar','4,38 / 182 x 22'],['Item 1','7,41 / 16 x 16; +20 x per slot'],['Action text','y=-12; centered; width follows text'],['Item name','y=1; centered; width follows text']];
  let table='';entries.forEach(([n,t],i)=>{let x=i<4?64:650,y=535+(i%4)*40;table+=`<text x="${x}" y="${y}" fill="#e9edf4" font-family="Arial" font-size="18">${n}</text><text x="${x+126}" y="${y}" fill="#9baec3" font-family="monospace" font-size="15">${t}</text>`;});
  const notes=`<text x="64" y="728" fill="#ffca70" font-family="Arial" font-size="17">Observed live: panel, armor, hearts, hunger, XP background, hotbar, item icons and HP/Mana text.</text><text x="64" y="760" fill="#9baec3" font-family="Arial" font-size="15">Offhand, air, XP level and item-name zones come from the client layout. XP-level width shown is a reserve.</text><text x="64" y="788" fill="#9baec3" font-family="Arial" font-size="15">Extra hearts/absorption, damage shaking, regeneration bobbing and riding can move or extend the vital rows.</text><text x="64" y="816" fill="#9baec3" font-family="Arial" font-size="15">Use the transparent 190 x 60 PNG at 100% in your pixel editor. This sheet is enlarged for reading.</text>`;
  await save('01-outline-guide',svg(1280,860,header+chart+table+notes));
  // Full framebuffer annotation: 8 physical pixels per GUI pixel, panel origin measured at 1160,1656.
  const png=fs.readFileSync(capture).toString('base64');
  const background=`<image href="data:image/png;base64,${png}" width="3840" height="2131"/>`;
  const observed=zones.filter(z=>!z[6]||z[6]==='observed');
  const overlay=`<g transform="translate(1160 1656) scale(8)">${observed.map(z=>rect(z)).join('')}</g>`;
  const labels=[['ACTION TEXT',1530,'#c894ff'],['PANEL TOP',1660,'#fff'],['ARMOR',1770,'#71b7ff'],['HEARTS / HUNGER',1850,'#ff658a'],['XP BAR',1930,'#b4e978'],['HOTBAR / ITEMS',2050,'#54e3d2']].map(([n,y,c])=>`<rect x="680" y="${y-29}" width="420" height="42" fill="#111720" fill-opacity=".94"/><text x="700" y="${y}" font-size="25" font-family="Arial" fill="${c}">${n}</text><path d="M1100 ${y-8}H1152" stroke="${c}" stroke-width="3"/>`).join('');
  await save('01-outline-on-capture',svg(3840,2131,background+overlay+labels));
  fs.writeFileSync(path.join(out,'geometry.json'),JSON.stringify({framebuffer:[3840,2131],gui:[480,267],guiScale:8,panelOriginPhysical:[1160,1656],bottomClipPhysicalPixels:5,zones:zones.map(([name,x,y,width,height,color,condition])=>({name,x,y,width,height,color,condition:condition||'observed'}))},null,2)+'\n');
})();
