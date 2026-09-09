-- @include mobility/windstep.inc
-- @include abilities/arrow_lanes.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextMark=40; s.nextShot=110
   player:send_message('&6Sniper Instructor: &fWait for the line to settle. That is when I stop following you.')
  end
  if (s.markUntil or 0)>s.tick and s.tick%10==0 then player:spawn_particle_at_self({particle='CRIT',amount=2},1) end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then arrow_lanes(c,s.aim,{0},1.1,false) end
   if s.tick>=s.fireAt then
    arrow_lanes(c,s.aim,{0},1.1,true); s.fireAt=nil; s.busyUntil=s.tick+116; s.exposedUntil=s.tick+116
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Sniper Instructor: &fA different angle. The same commitment.'); return
  end
  if s.tick>=s.nextMark then
   s.nextMark=s.tick+360; s.busyUntil=s.tick+46; c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_FLUTE',.6,1.3)
   c.scheduler:run_later(26,function() s.markUntil=s.tick+140 end)
  elseif s.tick>=s.nextShot then
   s.nextShot=s.tick+240; s.fireAt=s.tick+42; s.lockAt=s.tick+26; s.aim=player:get_eye_location()
   s.shotDamage=(s.markUntil or 0)>s.tick and 1.05 or .9
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_HARP',.6,.6)
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(c.state.shotDamage or .9) end end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.1) end
 end,
 on_death=function(c) c.boss:send_message('&6Sniper Instructor: &fThat was the commitment. You moved after it.',24) end
}
