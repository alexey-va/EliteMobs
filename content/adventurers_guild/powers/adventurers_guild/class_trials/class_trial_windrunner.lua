-- @include mobility/windstep.inc
-- @include mobility/strafe.inc
-- @include abilities/arrow_lanes.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextTailwind=60
   player:send_message('&6Windrunner Instructor: &fThree shots along the run. Each one gives you a fresh cue.')
  end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then arrow_lanes(c,s.aim,{0},1,false) end
   if s.tick>=s.fireAt then
    arrow_lanes(c,s.aim,{0},1,true); s.shot=s.shot+1
    if s.shot>3 then s.fireAt=nil; s.busyUntil=s.tick+120; s.exposedUntil=s.tick+120
    else s.fireAt=s.tick+26; s.lockAt=s.tick+14; s.aim=player:get_eye_location() end
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Windrunner Instructor: &fThe wind turns. The rhythm stays.'); return
  end
  if s.tick>=s.nextTailwind then
   s.nextTailwind=s.tick+360; s.shot=1; s.fireAt=s.tick+36; s.lockAt=s.tick+24; s.aim=player:get_eye_location()
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_FLUTE',.6,1.4)
   c.scheduler:run_later(20,function() strafe(c,player,68) end)
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.32) end end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.15) end
 end,
 on_death=function(c) c.boss:send_message('&6Windrunner Instructor: &fYou kept pace without chasing my footsteps. Well run.',24) end
}
