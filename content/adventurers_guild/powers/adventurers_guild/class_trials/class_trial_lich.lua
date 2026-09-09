-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc
-- @include abilities/arcane_bolt.inc
-- @include abilities/prepared_remains.inc

return {
 api_version=1,
 on_spawn=function(c) c.state.corpses=prepared_remains(c,2) end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextCoil=170; s.nextBolt=280
   player:send_message('&6Lich Instructor: &fThe vessel is no decoration. Decide whether you want to finish this once or twice.')
  end
  if s.vessel and not s.vessel:is_alive() then
   s.vessel=nil; s.busyUntil=s.tick+70; s.exposedUntil=s.tick+70; s.raiseAt=nil; s.boltAt=nil; pause_movement(c,70)
   player:send_message('&6Lich Instructor: &fYou understood its purpose. Most do not.')
  end
  -- A visible low-health recovery window, not protection from a lethal burst.
  if s.vessel and c.boss:get_health()<=c.boss:get_maximum_health()*.25 then
   s.vessel:remove_elite(); s.vessel=nil; s.raiseAt=nil; s.boltAt=nil
   s.busyUntil=s.tick+80; pause_movement(c,80); c.boss:set_invulnerable(true,40)
   c.boss:play_sound_at_self('BLOCK_RESPAWN_ANCHOR_DEPLETE',.6,.8)
   c.boss:send_message('&6Lich Instructor: &fThe vessel yields its last breath. Then there is only me.',24)
   for i=1,4 do c.scheduler:run_later(i*10,function()
    c.boss:restore_health(c.boss:get_maximum_health()*.015)
    c.boss:spawn_particle_at_self({particle='SOUL',amount=8},1)
   end) end
   return
  end
  if s.vessel and s.tick%5==0 then show_circle(c,ground_circle(c,s.vessel:get_location(),1.2),225,190,110) end
  if s.vesselAt then
   if s.tick%4==0 then show_circle(c,s.vesselZone,225,190,110) end
   if s.tick>=s.vesselAt then
    s.vesselAt=nil; s.vessel=c.world:spawn_custom_boss_at_location('class_trial_phylactery.yml',s.vesselPosition,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.vessel,'Lich phylactery could not spawn'); s.busyUntil=s.tick+40
   end
   return
  end
  if s.raiseAt then
   if not s.corpse:is_alive() then
    s.raiseAt=nil; s.busyUntil=s.tick+60; s.exposedUntil=s.tick+60; pause_movement(c,60); return
   end
   if s.tick%4==0 then show_circle(c,ground_circle(c,s.corpse:get_location(),1.2),160,105,200) end
   if s.tick>=s.raiseAt then
    s.undead=raise_undead(c,s.corpse); s.raiseAt=nil; s.busyUntil=s.tick+50
    if s.undead then c.boss:restore_health(c.boss:get_maximum_health()*.02) end
   end
   return
  end
  if s.boltAt then
   if s.tick%4==0 then spell_aim(c,s.aim) end
   if s.tick>=s.boltAt then spell_bolt(c,s.aim,.8); s.boltAt=nil; s.busyUntil=s.tick+80 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Lich Instructor: &fThe first ending approaches. Have you prepared for it?')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  local corpse=next_remains(c)
  if not s.vesselUsed then
   s.vesselUsed=true; local q=c.boss:get_location()
   s.vesselPosition={world=q.world,x=q.x+3,y=q.y,z=q.z+2}; s.vesselZone=ground_circle(c,s.vesselPosition,1.2)
   s.vesselAt=s.tick+40; s.pressure=0; pause_movement(c,80); c.boss:play_sound_at_self('BLOCK_RESPAWN_ANCHOR_CHARGE',.5,.8)
  elseif corpse and s.tick>=s.nextCoil and (not s.undead or not s.undead:is_alive()) then
   s.nextCoil=s.tick+440; s.corpse=corpse; s.raiseAt=s.tick+46; pause_movement(c,96)
   c.boss:play_sound_at_self('BLOCK_SOUL_SAND_HIT',.5,.6)
  elseif s.tick>=s.nextBolt then
   s.nextBolt=s.tick+180; s.boltAt=s.tick+30; s.aim=player:get_eye_location(); pause_movement(c,110)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if c.event.is_damage_transfer then return end
  local s=c.state
  if s.vesselAt then
   s.pressure=s.pressure+c.event.get_damage_amount()
   if s.pressure>=c.boss:get_maximum_health()*.035 then
    s.vesselAt=nil; s.busyUntil=s.tick+60; s.exposedUntil=s.tick+60; pause_movement(c,60)
    c.boss:send_message('&6Lich Instructor: &fYou interrupted the binding. There will be no second vessel.',24)
   end
  end
  if (s.exposedUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_player_damaged_by_boss=function(c)
  if c.event.projectile then
   c.event.multiply_damage_amount(.4)
   local player=c.players:current_target(); if player then player:apply_potion_effect('WEAKNESS',30,0) end
  end
 end,
 on_death=function(c) c.boss:send_message('&6Lich Instructor: &fA proper ending. I expect you to recognize one next time.',24) end
}
