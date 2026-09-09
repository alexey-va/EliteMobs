-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc
-- @include abilities/arcane_bolt.inc

-- An ordinary lantern anchors a finite native vex summon. Destroying the lantern
-- dismisses it; sustained separation breaks the shared ward and damage link.
local function sever(c,opening)
 local s=c.state; s.linkUntil=0; s.sharedWard=0; s.separated=0
 if opening then
  s.exposedUntil=(s.tick or 0)+60; s.busyUntil=s.exposedUntil; pause_movement(c,60)
  c.boss:send_message('&6Spiritbinder Instructor: &fA bond still needs someone at each end.',24)
  c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.6,1.4)
 end
end
local function share(c,fromBoss)
 local s=c.state
 if c.event.is_damage_transfer or not s.eidolon or not s.eidolon:is_alive()
   or (s.linkUntil or 0)<=(s.tick or 0) then return end
 if not fromBoss and c.event.entity.uuid~=s.eidolon.uuid then return end
 local amount=c.event.get_damage_amount(); if amount<=0 then return end
 local absorbed=math.min(amount,s.sharedWard or 0); s.sharedWard=(s.sharedWard or 0)-absorbed
 local remaining=amount-absorbed; local moved=0
 if remaining>0 and c.event:transfer_damage(fromBoss and s.eidolon or c.boss,remaining*.4) then moved=remaining*.4 end
 c.event.multiply_damage_amount((remaining-moved)/amount)
end
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.charges=2; s.nextLantern=45; s.nextLink=0; s.nextBolt=190
   player:send_message('&6Spiritbinder Instructor: &fThe lantern is its anchor. Follow the thread if you would break the bond.')
  end
  if s.eidolon and (not s.eidolon:is_alive() or not s.lantern or not s.lantern:is_alive() or s.tick>=s.summonUntil) then
   local broken=s.tick<s.summonUntil
   if s.eidolon:is_alive() then s.eidolon:remove_elite() end
   if s.lantern and s.lantern:is_alive() then s.lantern:remove_elite() end
   s.eidolon=nil; s.lantern=nil; s.linkAt=nil; sever(c,broken)
  end
  if (s.linkUntil or 0)>s.tick and s.eidolon then
   local p,q=c.boss:get_location(),s.eidolon:get_location()
   local close=math.abs(p.y-q.y)<6 and (p.x-q.x)^2+(p.z-q.z)^2<=36
   s.separated=close and 0 or (s.separated or 0)+1
   if s.separated>=20 then sever(c,true)
   elseif s.tick%5==0 then
    for i=0,10 do
     local t=i/10; c.world:spawn_particle_at_location({world=p.world,x=p.x+(q.x-p.x)*t,y=p.y+1+(q.y-p.y)*t,z=p.z+(q.z-p.z)*t},
      {particle='DUST',red=100,green=200,blue=245,amount=1},1)
    end
   end
  end
  if s.summonAt then
   if s.tick%4==0 then show_circle(c,s.marker,100,200,245) end
   if s.tick>=s.summonAt then
    s.summonAt=nil
    s.lantern=c.world:spawn_custom_boss_at_location('class_trial_eidolon_lantern.yml',s.anchor,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.lantern,'Eidolon Lantern could not spawn')
    s.eidolon=c.world:spawn_custom_boss_at_location('class_trial_bound_eidolon.yml',
     {world=s.anchor.world,x=s.anchor.x+1.5,y=s.anchor.y+1,z=s.anchor.z},
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.eidolon,'Bound Eidolon could not spawn'); s.summonUntil=s.tick+240; s.busyUntil=s.tick+50
   end
   return
  end
  if s.linkAt then
   if s.tick%4==0 then c.boss:spawn_particle_at_self({particle='ENCHANT',amount=7},1) end
   if s.tick>=s.linkAt then s.linkAt=nil; s.linkUntil=s.tick+120; s.sharedWard=c.boss:get_maximum_health()*.035; s.separated=0; s.busyUntil=s.tick+40 end
   return
  end
  if s.boltAt then
   if s.tick%4==0 then spell_aim(c,s.aim) end
   if s.tick>=s.boltAt then spell_bolt(c,s.aim,.7); s.boltAt=nil; s.busyUntil=s.tick+80 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Spiritbinder Instructor: &fSpace tests a bond as surely as steel.')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  if not s.eidolon and s.charges>0 and s.tick>=s.nextLantern then
   s.charges=s.charges-1; s.nextLantern=s.tick+520; local p=c.boss:get_location()
   s.anchor={world=p.world,x=p.x+3,y=p.y,z=p.z+3}; s.marker=ground_circle(c,s.anchor,1.2)
   s.summonAt=s.tick+40; pause_movement(c,90)
  elseif s.eidolon and s.tick>=s.nextLink then
   s.nextLink=s.tick+440; s.linkAt=s.tick+34; pause_movement(c,74)
   c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,1.6)
  elseif s.tick>=s.nextBolt then
   s.nextBolt=s.tick+180; s.boltAt=s.tick+30; s.aim=player:get_eye_location(); pause_movement(c,110)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
  share(c,true)
 end,
 on_reinforcement_damaged_by_player=function(c) share(c,false) end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.3) end end,
 on_death=function(c) c.boss:send_message('&6Spiritbinder Instructor: &fYou saw what held us together. Use that knowledge with care.',24) end
}
