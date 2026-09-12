-- @include mobility/windstep.inc
-- @include abilities/arrow_lanes.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextLock=40; s.nextBreach=120
   player:send_message('&6Arbalist Instructor: &fHeavy draw. Slow reload. Choose which one to challenge.')
  end
  if (s.markUntil or 0)>s.tick and s.tick%8==0 then player:spawn_particle_at_self({particle='CRIT',amount=2},1) end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then arrow_lanes(c,s.aim,{0},1.05,false) end
   if s.tick>=s.fireAt then
    arrow_lanes(c,s.aim,{0},1.05,true); s.fireAt=nil; s.busyUntil=s.tick+120; s.exposedUntil=s.tick+120
    c.boss:play_sound_at_self('ITEM_CROSSBOW_LOADING_MIDDLE',.5,.7)
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Arbalist Instructor: &fYou found the reload. Keep making me pay for it.'); return
  end
  if s.tick>=s.nextLock then
   s.nextLock=s.tick+400; s.busyUntil=s.tick+50; c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_FLUTE',.6,1.2)
   c.scheduler:run_later(30,function() s.markUntil=s.tick+160 end)
  elseif s.tick>=s.nextBreach then
   s.nextBreach=s.tick+300; s.fireAt=s.tick+38; s.lockAt=s.tick+24; s.aim=player:get_eye_location()
   c.boss:play_sound_at_self('ITEM_CROSSBOW_LOADING_START',.6,.7)
  end
 end,
 on_player_damaged_by_boss=function(c)
  if c.event.projectile then
   c.event.multiply_damage_amount((c.state.markUntil or 0)>(c.state.tick or 0) and .9 or .8)
   local player=c.players:current_target(); if player then player:apply_potion_effect('WEAKNESS',40,0) end
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.1) end
 end,
 on_death=function(c) c.boss:send_message('&6Arbalist Instructor: &fA loaded bow is dangerous. An empty one taught you more.',24) end
}
