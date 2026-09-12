-- @include ground_markers.inc
-- @include mobility/leap_slam.inc
-- @include abilities/earthshatter.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextBreach=50; s.nextImpact=170
   player:send_message('&6Siegebreaker Instructor: &fFirst the breach, then the hammer. Deny me the first.')
  end
  if (s.breachUntil or 0)>s.tick and s.tick%10==0 then player:spawn_particle_at_self({particle='CRIT',amount=2},1) end
  if s.breachAt then
   if s.tick%4==0 then show_circle(c,s.breach,240,160,80) end
   if s.tick>=s.breachAt then
    c.script:damage(s.breach:full_target(),1,.4)
    local p=player:get_location(); p.y=p.y+.75
    if s.breach:contains(p) then s.breachUntil=s.tick+140; c.boss:play_sound_at_self('ITEM_SHIELD_BREAK',.6,1) end
    s.breachAt=nil; s.busyUntil=s.tick+30
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Siegebreaker Instructor: &fYou have seen the opening. Now defend it.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextBreach then
   s.nextBreach=s.tick+360; s.breach=forward_cone(c,c.boss:get_location(),player:get_location(),3.2,1.5)
   s.breachAt=s.tick+30; pause_movement(c,60); c.boss:face_direction_or_location(player:get_location())
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_BASEDRUM',.5,.8)
  elseif s.tick>=s.nextImpact then s.nextImpact=s.tick+440; earthshatter(c,4,1) end
 end,
 on_player_damaged_by_boss=function(c)
  if (c.state.breachUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.15) end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Siegebreaker Instructor: &fNo wall breaks itself. You made me work for every inch.',24) end
}
