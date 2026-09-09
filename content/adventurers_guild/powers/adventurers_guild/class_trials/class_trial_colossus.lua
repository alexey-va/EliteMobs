-- @include ground_markers.inc
-- @include mobility/leap_slam.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextImmovable=40; s.nextBreaker=110
   player:send_message('&6Colossus Instructor: &fI commit everything to one blow. Make me regret where I aim it.')
  end
  if s.breakerAt then
   if s.tick%4==0 then show_circle(c,s.breaker,200,130,70) end
   if s.tick>=s.breakerAt then
    c.script:damage(s.breaker:full_target(),1,1.35)
    s.breakerAt=nil; s.armed=false; s.busyUntil=s.tick+80; s.exposedUntil=s.tick+80
    c.boss:play_sound_at_self('ENTITY_GENERIC_EXPLODE',.7,.5)
   end
   return
  end
  if s.armAt then
   if s.tick%5==0 then c.boss:spawn_particle_at_self({particle='WAX_ON',amount=3},1) end
   if s.tick>=s.armAt then s.armAt=nil; s.armed=true; s.busyUntil=s.tick+20 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Colossus Instructor: &fOne more commitment. Watch it carefully.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextImmovable then
   s.nextImmovable=s.tick+500; s.armAt=s.tick+30; pause_movement(c,50)
   c.boss:play_sound_at_self('ITEM_ARMOR_EQUIP_NETHERITE',.5,.5)
  elseif s.tick>=s.nextBreaker then
   s.nextBreaker=s.tick+480; s.breaker=forward_cone(c,c.boss:get_location(),player:get_location(),6,6)
   s.breakerAt=s.tick+50; s.pressure=0; pause_movement(c,130)
   c.boss:face_direction_or_location(player:get_location()); c.boss:play_sound_at_self('BLOCK_ANVIL_PLACE',.6,.5)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if c.event.is_damage_transfer then return end
  local s=c.state
  if s.breakerAt and s.armed then
   s.pressure=s.pressure+c.event.get_damage_amount(); c.event.multiply_damage_amount(.6)
   if s.pressure>=c.boss:get_maximum_health()*.06 then
    s.breakerAt=nil; s.armed=false; s.busyUntil=s.tick+80; s.exposedUntil=s.tick+80; pause_movement(c,80)
    c.boss:play_sound_at_self('ITEM_SHIELD_BREAK',.6,.6)
    c.boss:send_message('&6Colossus Instructor: &fYou broke the commitment. Take what it cost me.',24)
   end
  elseif (s.exposedUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.25) end
 end,
 on_death=function(c) c.boss:send_message('&6Colossus Instructor: &fAll that force, and you found the space beside it. Well done.',24) end
}
