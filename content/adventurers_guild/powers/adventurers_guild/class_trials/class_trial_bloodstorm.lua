-- @include ground_markers.inc
-- @include mobility/leap_slam.inc

return {
 api_version=1,
 on_spawn=function(c) c.state.healingLeft=c.boss:get_maximum_health()*.12 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextTrail=40; s.nextCyclone=150
   player:send_message('&6Bloodstorm Instructor: &fBlood on the ground, steel in a circle. Draw me out of both.')
  end
  if (s.trailUntil or 0)>s.tick then
   if s.tick%5==0 then show_circle(c,s.trail,170,30,50) end
   if s.tick%20==0 and s.trail:contains(c.boss:get_location()) and s.healingLeft>0 then
    local amount=math.min(s.healingLeft,c.boss:get_maximum_health()*.01,c.boss:get_maximum_health()-c.boss:get_health())
    if amount>0 then c.boss:restore_health(amount); s.healingLeft=s.healingLeft-amount end
   end
  end
  if s.trailAt then
   if s.tick%4==0 then show_circle(c,s.trail,170,30,50) end
   if s.tick>=s.trailAt then s.trailAt=nil; s.trailUntil=s.tick+120; s.busyUntil=s.tick+30 end
   return
  end
  if s.spinAt then
   if s.tick%4==0 then show_circle(c,ground_circle(c,c.boss:get_location(),3),215,55,65) end
   if s.tick>=s.spinAt then
    c.script:damage(ground_circle(c,c.boss:get_location(),3):full_target(),1,.35)
    c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.6,.7)
    s.pulse=s.pulse+1
    if s.pulse>3 then s.spinAt=nil; s.busyUntil=s.tick+60; s.exposedUntil=s.tick+60; pause_movement(c,60)
    else s.spinAt=s.tick+20 end
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Bloodstorm Instructor: &fMake me chase you. The pool cannot follow.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextTrail then
   s.nextTrail=s.tick+440; s.trail=ground_circle(c,c.boss:get_location(),3)
   s.trailAt=s.tick+32; pause_movement(c,62); c.boss:play_sound_at_self('BLOCK_GRAVEL_BREAK',.5,.7)
  elseif s.tick>=s.nextCyclone then
   s.nextCyclone=s.tick+380; s.pulse=1; s.spinAt=s.tick+38
   local destination=player:get_location(); pause_movement(c,38)
   c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.5,.5)
   c.scheduler:run_later(38,function() c.boss:navigate_to_location(destination,.55,false,40) end)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Bloodstorm Instructor: &fYou found the edge of the storm. Keep that instinct.',24) end
}
