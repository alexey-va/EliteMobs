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
   s.started=true; s.nextDrain=50; s.nextChill=170; s.nextBolt=260
   player:send_message('&6Necromancer Instructor: &fThose remains are a resource. You may remove them, if you are quick enough.')
  end
  if s.candle then
   if not s.candle:is_alive() or s.tick>=s.chillUntil then
    if s.candle:is_alive() then s.candle:remove_elite() end; s.candle=nil
   elseif s.tick%5==0 then
    show_circle(c,s.chill,100,185,220)
    if s.chill:contains(player:get_location()) then
     player:apply_potion_effect('SLOWNESS',10,0); player:apply_potion_effect('WEAKNESS',10,0)
    end
   end
  end
  if s.raiseAt then
   if not s.corpse:is_alive() then
    s.raiseAt=nil; s.busyUntil=s.tick+60; s.exposedUntil=s.tick+60; pause_movement(c,60)
    player:send_message('&6Necromancer Instructor: &fWasteful. Effective, unfortunately.'); return
   end
   if s.tick%4==0 then show_circle(c,ground_circle(c,s.corpse:get_location(),1.2),150,90,190) end
   if s.tick>=s.raiseAt then
    s.undead=raise_undead(c,s.corpse); s.raiseAt=nil; s.busyUntil=s.tick+50
    if s.undead then c.boss:restore_health(c.boss:get_maximum_health()*.02) end
   end
   return
  end
  if s.chillAt then
   if s.tick%4==0 then show_circle(c,s.chill,100,185,220) end
   if s.tick>=s.chillAt then
    s.chillAt=nil; s.candle=c.world:spawn_custom_boss_at_location('class_trial_grave_candle.yml',s.chillPosition,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.candle,'Grave candle could not spawn'); s.chillUntil=s.tick+80; s.busyUntil=s.tick+40
   end
   return
  end
  if s.boltAt then
   if s.tick%4==0 then spell_aim(c,s.aim) end
   if s.tick>=s.boltAt then spell_bolt(c,s.aim,.75); s.boltAt=nil; s.busyUntil=s.tick+80 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Necromancer Instructor: &fVery thorough. I shall have to work with what remains.')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  local corpse=next_remains(c)
  if corpse and s.tick>=s.nextDrain and (not s.undead or not s.undead:is_alive()) then
   s.nextDrain=s.tick+440; s.corpse=corpse; s.raiseAt=s.tick+46; pause_movement(c,96)
   c.boss:play_sound_at_self('BLOCK_SOUL_SAND_HIT',.6,.6)
  elseif s.tick>=s.nextChill and not s.candle then
   s.nextChill=s.tick+400; s.chillPosition=player:get_location(); s.chill=ground_circle(c,s.chillPosition,3)
   s.chillAt=s.tick+32; pause_movement(c,72); c.boss:play_sound_at_self('BLOCK_SOUL_SAND_HIT',.5,.8)
  elseif s.tick>=s.nextBolt then
   s.nextBolt=s.tick+180; s.boltAt=s.tick+30; s.aim=player:get_eye_location(); pause_movement(c,110)
   c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.5,.7)
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.35) end end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Necromancer Instructor: &fNo useful remains, no convenient opening. You are learning.',24) end
}
