-- @include ground_markers.inc
-- @include mobility/steed_charge.inc
-- @include abilities/three_swing_drill.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextSalute=40; s.nextDominion=150
   player:send_message('&6Champion Instructor: &fA salute, then three strokes. Do not mistake the pause for the end.')
  end
  if s.saluteAt then
   if s.tick%4==0 then show_circle(c,s.salute,245,215,135) end
   if s.tick>=s.saluteAt then
    if s.salute:contains(player:get_location()) then
     player:push_relative_to(c.boss:get_location(),.2,0,.06,0); s.duelUntil=s.tick+100
    end
    s.saluteAt=nil; s.busyUntil=s.tick+30
   end
   return
  end
  if (s.duelUntil or 0)>s.tick and s.tick%10==0 then player:spawn_particle_at_self({particle='CRIT',amount=2},1) end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.busyUntil=s.tick+65; steed_charge(c,player)
   player:send_message('&6Champion Instructor: &fGood. Now keep that composure at a faster pace.')
  elseif s.tick>=s.nextDominion then
   s.nextDominion=s.tick+360
   three_swing_drill(c,player,s.phaseTwo and {26,20,26} or {30,24,30},{.3,.3,.65})
  elseif s.tick>=s.nextSalute then
   s.nextSalute=s.tick+340; s.salute=forward_cone(c,c.boss:get_location(),player:get_location(),4,2)
   s.saluteAt=s.tick+28; pause_movement(c,58)
   c.boss:face_direction_or_location(player:get_location()); c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.6,1.3)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_player_damaged_by_boss=function(c)
  if (c.state.duelUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.1) end
 end,
 on_death=function(c) c.boss:send_message('&6Champion Instructor: &fThe final salute is yours. You have earned it.',24) end
}
