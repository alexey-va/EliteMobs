-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc
-- @include abilities/arcane_bolt.inc
-- @include abilities/prepared_remains.inc

return {
 api_version=1,
 on_spawn=function(c) c.state.corpses=prepared_remains(c,3) end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextRaise=50; s.nextMiasma=180; s.nextBolt=270
   player:send_message('&6Plaguebringer Instructor: &fThe rot begins with a body. Deal with the cause, or keep clear of its ground.')
  end
  if s.trail and (not s.undead or not s.undead:is_alive()) then s.trail=nil; s.trailAt=nil; s.miasmaAt=nil; s.miasmaUntil=0 end
  if (s.miasmaUntil or 0)>s.tick and s.tick%5==0 then
   show_circle(c,s.miasma,125,170,70)
   if s.miasma:contains(player:get_location()) then
    player:apply_potion_effect('SLOWNESS',10,0); player:apply_potion_effect('WEAKNESS',10,0)
   end
  end
  if s.raiseAt then
   if not s.corpse:is_alive() then
    s.raiseAt=nil; s.busyUntil=s.tick+60; s.exposedUntil=s.tick+60; pause_movement(c,60)
    player:send_message('&6Plaguebringer Instructor: &fYou removed the source. Irritatingly sensible.'); return
   end
   if s.tick%4==0 then show_circle(c,ground_circle(c,s.corpse:get_location(),1.2),125,170,70) end
   if s.tick>=s.raiseAt then
    s.undead=raise_undead(c,s.corpse); s.raiseAt=nil; s.busyUntil=s.tick+30
    if s.undead then
     local a,b=s.undead:get_location(),player:get_location(); local dx,dz=b.x-a.x,b.z-a.z
     local d=math.max(.01,math.sqrt(dx*dx+dz*dz)); s.trail={}
     for i=1,3 do s.trail[i]=ground_circle(c,{world=a.world,x=a.x+dx/d*(i-1)*2.5,y=a.y,z=a.z+dz/d*(i-1)*2.5},1.6) end
     s.trailAt=s.tick+36; s.patch=1
    end
   end
   return
  end
  if s.trailAt then
   if s.tick%4==0 then for _,zone in ipairs(s.trail) do show_circle(c,zone,125,170,70) end end
   if s.tick>=s.trailAt then
    c.script:damage(s.trail[s.patch]:full_target(),1,.25); s.patch=s.patch+1
    if s.patch>3 then s.trailAt=nil; s.busyUntil=s.tick+40
    else s.trailAt=s.tick+20 end
   end
   return
  end
  if s.miasmaAt then
   if s.tick%4==0 then show_circle(c,s.miasma,125,170,70) end
   if s.tick>=s.miasmaAt then s.miasmaAt=nil; s.miasmaUntil=s.tick+80; s.busyUntil=s.tick+40 end
   return
  end
  if s.boltAt then
   if s.tick%4==0 then spell_aim(c,s.aim) end
   if s.tick>=s.boltAt then spell_bolt(c,s.aim,.7); s.boltAt=nil; s.busyUntil=s.tick+80 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Plaguebringer Instructor: &fStill clean boots? We can correct that.')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  local corpse=next_remains(c)
  if corpse and s.tick>=s.nextRaise and (not s.undead or not s.undead:is_alive()) then
   s.nextRaise=s.tick+440; s.corpse=corpse; s.raiseAt=s.tick+46; pause_movement(c,162)
   c.boss:play_sound_at_self('BLOCK_BREWING_STAND_BREW',.5,.7)
  elseif s.undead and s.undead:is_alive() and s.tick>=s.nextMiasma then
   s.nextMiasma=s.tick+440; s.miasma=ground_circle(c,c.boss:get_location(),3.5)
   s.miasmaAt=s.tick+34; pause_movement(c,74); c.boss:play_sound_at_self('BLOCK_BREWING_STAND_BREW',.5,.9)
  elseif s.tick>=s.nextBolt then
   s.nextBolt=s.tick+180; s.boltAt=s.tick+30; s.aim=player:get_eye_location(); pause_movement(c,110)
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.35) end end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Plaguebringer Instructor: &fYou dealt with the cause. A rare habit. Keep it.',24) end
}
