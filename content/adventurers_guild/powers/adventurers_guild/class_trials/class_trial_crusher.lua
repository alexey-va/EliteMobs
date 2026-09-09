-- @include ground_markers.inc
-- @include mobility/leap_slam.inc
-- @include abilities/earthshatter.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextFault=50; s.nextQuake=220
   player:send_message('&6Crusher Instructor: &fThe crack travels forward. Step across it.')
  end
  if s.faultAt then
   if s.tick%4==0 then for _,zone in ipairs(s.sections) do show_circle(c,zone,160,135,110) end end
   if s.tick>=s.faultAt then
    local zone=s.sections[s.section]
    c.script:damage(zone:full_target(),1,.3)
    c.boss:play_sound_at_self('BLOCK_STONE_BREAK',.6,.7+s.section*.15)
    s.section=s.section+1
    if s.section>3 then s.faultAt=nil; s.busyUntil=s.tick+56; s.exposedUntil=s.tick+56
    else s.faultAt=s.tick+10 end
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Crusher Instructor: &fFurther this time. Keep watching the stone.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextFault then
   s.nextFault=s.tick+340; s.sections={}; s.section=1; s.faultAt=s.tick+34
   local p,q=c.boss:get_location(),player:get_location(); local dx,dz=q.x-p.x,q.z-p.z
   local d=math.max(.01,math.sqrt(dx*dx+dz*dz)); dx,dz=dx/d,dz/d
   for i=1,3 do s.sections[i]=ground_circle(c,{world=p.world,x=p.x+dx*i*2.5,y=p.y,z=p.z+dz*i*2.5},1.4) end
   pause_movement(c,110); c.boss:face_direction_or_location(q); c.boss:play_sound_at_self('BLOCK_STONE_BREAK',.6,.5)
  elseif s.tick>=s.nextQuake then s.nextQuake=s.tick+400; earthshatter(c,4,.95) end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Crusher Instructor: &fYou read the fault before it reached you. Good feet.',24) end
}
