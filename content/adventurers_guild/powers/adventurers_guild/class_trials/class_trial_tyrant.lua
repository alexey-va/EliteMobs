-- @include ground_markers.inc
-- @include mobility/steed_charge.inc

-- Three successive ground circles leave a visibly marked escape direction.
-- Crossing out of the circle is always sufficient; no invisible movement lock.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextKneel=50; s.nextEscape=220
   player:send_message('&6Tyrant Instructor: &fI will demand your ground. Make me fight for it.')
  end
  if s.kneelAt then
   if s.tick%4==0 then show_circle(c,s.kneel,185,85,55) end
   if s.tick>=s.kneelAt then
    if s.kneel:contains(player:get_location()) then
     player:push_relative_to(c.boss:get_location(),.28,0,.08,0); player:apply_potion_effect('WEAKNESS',40,0)
    end
    s.kneelAt=nil; s.busyUntil=s.tick+40; s.exposedUntil=s.tick+40
   end
   return
  end
  if s.escapeAt then
   if s.tick%4==0 then
    show_circle(c,s.escape,185,85,55); show_circle(c,s.safe,245,220,130)
   end
   if s.tick>=s.escapeAt then
    local p=player:get_location(); p.y=p.y+.75
    if s.escape:contains(player:get_location()) and not s.safe:contains(p) then
     player:apply_potion_effect('SLOWNESS',20,0)
     c.script:damage(ground_circle(c,player:get_location(),.5):full_target(),1,.35)
    end
    s.pulse=s.pulse+1
    if s.pulse>3 then s.escapeAt=nil; s.busyUntil=s.tick+60; s.exposedUntil=s.tick+60
    else s.escapeAt=s.tick+20; s.escape=ground_circle(c,s.center,5-s.pulse*.6) end
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.busyUntil=s.tick+65; steed_charge(c,player)
   player:send_message('&6Tyrant Instructor: &fYou refuse to kneel. Show me you can hold that answer.')
  elseif s.tick>=s.nextKneel then
   s.nextKneel=s.tick+380; s.kneel=ground_circle(c,c.boss:get_location(),4)
   s.kneelAt=s.tick+36; pause_movement(c,76); c.boss:play_sound_at_self('BLOCK_ANVIL_LAND',.5,.7)
  elseif s.tick>=s.nextEscape then
   s.nextEscape=s.tick+440; s.center=c.boss:get_location(); s.escape=ground_circle(c,s.center,5)
   local target=player:get_location(); local dx,dz=target.x-s.center.x,target.z-s.center.z
   local side=s.phaseTwo and 1 or -1
   s.safe=forward_cone(c,s.center,{x=s.center.x-dz*side,y=s.center.y,z=s.center.z+dx*side},7,3)
   s.escapeAt=s.tick+40; s.pulse=1; pause_movement(c,140)
   c.boss:play_sound_at_self('ENTITY_RAVAGER_ROAR',.5,.6)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Tyrant Instructor: &fYou kept your footing. I have nothing more to demand.',24) end
}
