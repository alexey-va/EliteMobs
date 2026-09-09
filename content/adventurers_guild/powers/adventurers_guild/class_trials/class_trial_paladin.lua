-- @include ground_markers.inc
-- @include mobility/steed_charge.inc

-- Provoke invites frontal pressure; going around the shield breaks the guard.
-- Repulse is a separate short-range bell tell, with time to leave its circle.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextGuard=60; s.nextRepulse=210
   player:send_message('&6Paladin Instructor: &fA shield has a front. Show me that you understand its back.')
  end
  if s.guardUntil then
   if s.tick%5==0 then show_circle(c,s.guard,245,215,110) end
   if s.tick>=s.guardUntil then
    s.guardUntil=nil; s.counterAt=s.tick+24
    s.counter=forward_cone(c,c.boss:get_location(),player:get_location(),3.5,1.8)
   end
   return
  end
  if s.counterAt then
   if s.tick%4==0 then show_circle(c,s.counter,235,170,65) end
   if s.tick>=s.counterAt then
    if s.pressure>=c.boss:get_maximum_health()*.08 then c.script:damage(s.counter:full_target(),1,.65) end
    s.counterAt=nil; s.recoveryUntil=s.tick+40
   end
   return
  end
  if s.repulseAt then
   if s.tick%4==0 then show_circle(c,s.repulse,245,215,110) end
   if s.tick>=s.repulseAt then
    c.script:damage(s.repulse:full_target(),1,.45)
    if s.repulse:contains(player:get_location()) then player:push_relative_to(c.boss:get_location(),.3,0,.08,0) end
    s.repulseAt=nil; s.recoveryUntil=s.tick+30
   end
   return
  end
  if s.tick<(s.recoveryUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.recoveryUntil=s.tick+65
   player:send_message('&6Paladin Instructor: &fMake room. The charge is committed once it begins.')
   steed_charge(c,player)
  elseif s.tick>=s.nextGuard then
   s.nextGuard=s.tick+280; s.pressure=0; s.guardUntil=s.tick+80
   s.guard=forward_cone(c,c.boss:get_location(),player:get_location(),5,3)
   c.boss:face_direction_or_location(player:get_location()); c.boss:set_ai_enabled(false,144)
   c.boss:play_sound_at_self('ITEM_SHIELD_BLOCK',.6,.7)
  elseif s.tick>=s.nextRepulse then
   s.nextRepulse=s.tick+300; s.repulseAt=s.tick+28
   s.repulse=ground_circle(c,c.boss:get_location(),3.5)
   c.boss:set_ai_enabled(false,58); c.boss:play_sound_at_self('BLOCK_BELL_USE',.6,1.1)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if not s.guardUntil or c.event.is_damage_transfer then return end
  local player=c.players:current_target()
  local position=player and player:get_location()
  if position then position.y=position.y+.75 end
  if position and s.guard:contains(position) then
   s.pressure=s.pressure+c.event.get_damage_amount(); c.event.multiply_damage_amount(.4)
   c.boss:play_sound_at_self('ITEM_SHIELD_BLOCK',.4,.8)
  else
   s.guardUntil=nil; s.recoveryUntil=s.tick+40
   c.scheduler:run_later(40,function() c.boss:set_ai_enabled(true) end)
   if player then player:send_message('&6Paladin Instructor: &fThere. A shield has a back.') end
  end
 end,
 on_death=function(c)
  c.boss:send_message('&6Paladin Instructor: &fYou found the opening without abandoning your footing. Well fought.',24)
 end
}


