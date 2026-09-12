-- @include ground_markers.inc
-- @include mobility/leap_slam.inc
-- @include abilities/earthshatter.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextShatter=70; s.nextIron=40
   player:send_message('&6Juggernaut Instructor: &fHeavy feet. Heavy blows. There is room between them.')
  end
  if s.ironAt then
   if s.tick%5==0 then show_circle(c,ground_circle(c,c.boss:get_location(),1.3),240,215,145) end
   if s.tick>=s.ironAt then s.ironAt=nil; s.ironUntil=s.tick+100; s.busyUntil=s.tick+30 end
   return
  end
  if (s.ironUntil or 0)>s.tick and s.tick%10==0 then c.boss:spawn_particle_at_self({particle='WAX_ON',amount=3},1) end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Juggernaut Instructor: &fThe ground will tell you where I land.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextIron then
   s.nextIron=s.tick+440; s.ironAt=s.tick+28; pause_movement(c,58)
   c.boss:play_sound_at_self('ITEM_ARMOR_EQUIP_NETHERITE',.6,.7)
  elseif s.tick>=s.nextShatter then s.nextShatter=s.tick+360; earthshatter(c,3.5,.85) end
 end,
 on_boss_damaged_by_player=function(c)
  if c.event.is_damage_transfer then return end
  if (c.state.ironUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(.7) end
  if (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Juggernaut Instructor: &fYou moved when I could not. Remember that advantage.',24) end
}
