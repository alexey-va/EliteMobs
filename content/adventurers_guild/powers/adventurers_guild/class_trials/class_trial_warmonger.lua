-- @include ground_markers.inc
-- @include mobility/leap_slam.inc
-- @include abilities/three_swing_drill.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextChallenge=50; s.nextEngine=180
   player:send_message('&6Warmonger Instructor: &fNoise wins nothing. Keep your eyes on the weapon.')
  end
  if s.challengeAt then
   if s.tick%4==0 then show_circle(c,s.challenge,210,100,70) end
   if s.tick>=s.challengeAt then
    local q=player:get_location(); q.y=q.y+.75
    if s.challenge:contains(q) then
     player:apply_potion_effect('WEAKNESS',30,0); player:push_relative_to(c.boss:get_location(),.25,0,.05,0)
    end
    s.challengeAt=nil; s.busyUntil=s.tick+30
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Warmonger Instructor: &fStill calm? Let us see how long that lasts.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextChallenge then
   s.nextChallenge=s.tick+360; s.challenge=forward_cone(c,c.boss:get_location(),player:get_location(),5,5)
   s.challengeAt=s.tick+34; pause_movement(c,64); c.boss:face_direction_or_location(player:get_location())
   c.boss:play_sound_at_self('ITEM_GOAT_HORN_SOUND_1',.6,.8)
  elseif s.tick>=s.nextEngine then
   s.nextEngine=s.tick+440; three_swing_drill(c,player,{32,26,32},{.3,.35,.45})
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Warmonger Instructor: &fI made all the noise. You chose the winning moment.',24) end
}
