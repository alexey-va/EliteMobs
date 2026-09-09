-- @include mobility/windstep.inc
-- @include abilities/arrow_lanes.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextMark=40; s.nextShot=130
   player:send_message('&6Deadeye Instructor: &fThree notes. One arrow. Make the last note your cue.')
  end
  if s.resolveAt and s.tick>=s.resolveAt then
   s.resolveAt=nil
   if not s.connected then s.markUntil=0; s.exposedUntil=s.tick+70; player:send_message('&6Deadeye Instructor: &fA perfect line. An empty one.') end
  end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then arrow_lanes(c,s.aim,{0},1.4,false) end
   if (s.fireAt-s.tick)%16==0 then c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.6,1.4-(s.fireAt-s.tick)/80) end
   if s.tick>=s.fireAt then
    arrow_lanes(c,s.aim,{0},1.4,true); s.fireAt=nil; s.connected=false; s.resolveAt=s.tick+60; s.busyUntil=s.tick+130
   end
   return
  end
  if (s.markUntil or 0)>s.tick and s.tick%8==0 then player:spawn_particle_at_self({particle='CRIT',amount=2},1) end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Deadeye Instructor: &fI need one opening. You need only deny it.'); return
  end
  if s.tick>=s.nextMark then
   s.nextMark=s.tick+440; s.busyUntil=s.tick+50; c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_FLUTE',.6,1.3)
   c.scheduler:run_later(30,function() s.markUntil=s.tick+180 end)
  elseif s.tick>=s.nextShot then
   s.nextShot=s.tick+360; s.fireAt=s.tick+48; s.lockAt=s.tick+28; s.aim=player:get_eye_location()
   s.shotDamage=(s.markUntil or 0)>s.tick and 1.3 or 1.1
  end
 end,
 on_player_damaged_by_boss=function(c)
  if c.event.projectile then c.state.connected=true; c.event.multiply_damage_amount(c.state.shotDamage or 1.1) end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Deadeye Instructor: &fYou heard the last note. That was all you needed.',24) end
}
