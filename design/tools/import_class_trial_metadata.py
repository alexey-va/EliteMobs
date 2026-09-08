"""Import the approved prose presentation into explicit encounter metadata (never invent mechanics)."""
from pathlib import Path
import re
import yaml
ROOT=Path(__file__).resolve().parents[2]
ROOTS={
 'paladin':('The Oath Holds','MACE','SHIELD','IRON',[
 'A shield buys time. Show me what you do with it.',
 'Good. Now hold your nerve when the line moves.',
 'You found the opening without abandoning your ground. Take the oath.',
 'You watched the shield and missed the rider. We can practice again.']),
 'berserker':('Fury With a Purpose','IRON_AXE',None,'LEATHER',[
 'Anyone can swing angry. Show me you can stop.',
 'There! Keep that fire. Keep your head, too.',
 'You waited for the right swing. Now make it count out there.',
 "You chased every opening, even the ones I hadn't given you yet."]),
 'ranger':('Between the Shots','BOW',None,'LEATHER',[
 'Watch the bow. Move when I commit, not when I look at you.',
 "You've found the gap. Let's see you find the next one.",
 'You read the shot before it left the string. Welcome to the trail.',
 'You tried to outrun the arrow. Make me aim at where you used to be.']),
 'cleric':('A Place to Recover','MACE',None,'LEATHER',[
 'Watch where healing comes from. You can answer it without haste.',
 'Well timed. Now follow the light to the one who needs it.',
 'You saw the whole fight, not just the person before you. That is the gift.',
 'Take a breath. You can step out, choose your moment, and begin again.']),
 'spellcaster':('The Space Between Spells','BLAZE_ROD','BOOK','LEATHER',[
 'A spell has a beginning and an end. Fight in the space between.',
 'One pattern understood. Now keep it in mind while I add another.',
 'You stopped chasing the light and started reading the caster. Good.',
 'You moved at the flash. Listen for the breath before it.'])}
HANDS={
 'paladin':'guardian:IRON_SPEAR aegis:IRON_SWORD bulwark:MACE shieldbearer:IRON_SWORD justicar:MACE templar:MACE inquisitor:IRON_SWORD warlord:IRON_SWORD marshal:IRON_SPEAR bannerlord:IRON_SPEAR strategist:IRON_SWORD conqueror:IRON_SWORD tyrant:IRON_AXE champion:IRON_SWORD',
 'berserker':'bloodrager:IRON_AXE reaver:IRON_AXE bloodstorm:IRON_HOE deathless:IRON_AXE slayer:IRON_SWORD headsman:IRON_AXE harvester:IRON_HOE juggernaut:MACE crusher:MACE siegebreaker:MACE titanbane:IRON_SPEAR dreadnought:MACE warmonger:IRON_AXE colossus:MACE',
 'ranger':'sniper:BOW bowmaster:BOW deadeye:BOW raincaller:BOW arbalist:CROSSBOW artillerist:CROSSBOW dragonslayer:CROSSBOW skirmisher:BOW windrunner:BOW pathfinder:BOW tempest_archer:BOW saboteur:CROSSBOW trapper:CROSSBOW demolitionist:CROSSBOW',
 'cleric':'priest:MACE hierophant:MACE saint:TRIDENT exorcist:MACE oracle:TRIDENT fateweaver:IRON_SPEAR seraph:IRON_SPEAR shaman:TRIDENT lifewarden:IRON_HOE grovekeeper:IRON_HOE shepherd:IRON_SPEAR spiritcaller:MACE mistweaver:TRIDENT soulwarden:IRON_HOE',
 'spellcaster':'mage:BLAZE_ROD elementalist:WOODEN_SPEAR pyromancer:WOODEN_SPEAR cryomancer:WOODEN_SPEAR battlemage:BLAZE_ROD spellblade:BLAZE_ROD arcane_knight:BLAZE_ROD occultist:WOODEN_SPEAR necromancer:WOODEN_SPEAR lich:WOODEN_SPEAR plaguebringer:WOODEN_SPEAR summoner:BLAZE_ROD demonologist:WOODEN_SPEAR spiritbinder:BLAZE_ROD'}
OUT=ROOT/'src/main/resources/class_trials/encounters'
OUT.mkdir(parents=True,exist_ok=True)
count=0
for root,(title,hand,off,armor,voice) in ROOTS.items():
 entries=[(root,title,hand,voice)]
 text=(ROOT/f'design/class-trials-{root}.md').read_text(encoding='utf-8')
 hands=dict(pair.split(':') for pair in HANDS[root].split())
 blocks=re.split(r'^## ',text,flags=re.M)[1:]
 for block in blocks:
  heading,body=block.split('\n',1)
  form,title=heading.split(' — ',1)
  beats=[]
  for key in ('Open','Half','Win','Loss'):
   match=re.search(key+r':\s*“(.*?)”',body,re.S)
   if not match: raise ValueError(f'Missing {form} {key}')
   beats.append(' '.join(match.group(1).split()))
  entries.append((form,title,hands[form],beats))
 for form,title,hand,voice in entries:
  equipment={'HAND':hand,'CHEST':armor+'_CHESTPLATE','LEGS':armor+'_LEGGINGS','FEET':armor+'_BOOTS'}
  if root=='paladin' and form in ('paladin','guardian','aegis','bulwark','shieldbearer','justicar','templar'): equipment['OFF_HAND']='SHIELD'
  elif form in ('arcane_knight','soulwarden'): equipment['OFF_HAND']='SHIELD'
  elif root=='spellcaster': equipment['OFF_HAND']='BOOK'
  skin='necromancer' if form in ('necromancer','lich','plaguebringer') else 'pyromancer' if form=='pyromancer' else root
  data={'id':form,'title':title,'skin':skin,'equipment':equipment,'voice':dict(zip(('opening','halfway','victory','defeat'),voice))}
  (OUT/f'{form}.yml').write_text(yaml.safe_dump(data,sort_keys=False,allow_unicode=True,width=110),encoding='utf-8')
  count+=1
print(f'Imported {count} explicit presentation assets; Lua mechanics remain separately authored.')
