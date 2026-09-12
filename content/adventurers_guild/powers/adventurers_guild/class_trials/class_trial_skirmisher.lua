-- @include mobility/windstep.inc
-- @include mobility/strafe.inc
-- @include abilities/arrow_lanes.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextVolley=60; s.shots=0
   player:send_message('&6Skirmisher Instructor: &fMy feet move. The arrow still has to commit.')
  end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then arrow_lanes(c,s.aim,{-22,0,22},.95,false) end
   if s.tick>=s.fireAt then
    arrow_lanes(c,s.aim,{-22,0,22},.95,true); s.fireAt=nil; s.busyUntil=s.tick+110
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Skirmisher Instructor: &fOther side. Keep watching the bow.'); return
  end
  if s.tick>=s.nextVolley then
   s.nextVolley=s.tick+240; s.shots=s.shots+1; s.fireAt=s.tick+34; s.lockAt=s.tick+20; s.aim=player:get_eye_location()
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_HARP',.6,.7)
   if s.shots%2==0 then strafe(c,player,50); s.huntUntil=s.tick+100 end
  end
 end,
 on_player_damaged_by_boss=function(c)
  if c.event.projectile then c.event.multiply_damage_amount((c.state.huntUntil or 0)>(c.state.tick or 0) and .32 or .28) end
 end,
 on_death=function(c) c.boss:send_message('&6Skirmisher Instructor: &fYou followed the shot through the movement. Keep that eye.',24) end
}
