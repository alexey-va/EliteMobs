-- @include ground_markers.inc
-- @include mobility/leap_slam.inc
-- @include abilities/blood_scent.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextCondemn=40; s.nextStroke=130
   player:send_message('&6Headsman Instructor: &fThe blade falls straight. Your escape should not be.')
  end
  show_blood_scent(c,player)
  if s.strokeAt then
   if s.tick%4==0 then show_circle(c,s.stroke,190,45,45) end
   if s.tick>=s.strokeAt then
    local strength=(s.markUntil or 0)>s.tick and player:get_health()<player:get_maximum_health()*.35 and 1.3 or 1
    c.script:damage(s.stroke:full_target(),1,strength)
    local q=player:get_location(); q.y=q.y+.75
    if not s.stroke:contains(q) then s.markUntil=0 end
    s.strokeAt=nil; s.busyUntil=s.tick+70; s.exposedUntil=s.tick+70
    c.boss:play_sound_at_self('ENTITY_GENERIC_EXPLODE',.5,.6)
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Headsman Instructor: &fKeep your eyes up. One clean answer is all I ask.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextCondemn then s.nextCondemn=s.tick+400; blood_scent(c,120)
  elseif s.tick>=s.nextStroke then
   s.nextStroke=s.tick+360; s.stroke=forward_cone(c,c.boss:get_location(),player:get_location(),6,1)
   s.strokeAt=s.tick+44; pause_movement(c,114); c.boss:face_direction_or_location(player:get_location())
   c.boss:play_sound_at_self('BLOCK_ANVIL_PLACE',.6,.6)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.25) end
 end,
 on_death=function(c) c.boss:send_message('&6Headsman Instructor: &fAcross the blade. Exactly so.',24) end
}
