-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc

-- Each element has its own marked area. The order changes once, at half health.
-- Exposure empowers one full sequence, then the long recovery exposes the caster.
local colors={{245,110,45},{100,200,245},{185,115,245}}
local function prepare_element(c,player)
 local s=c.state; s.element=s.order[s.sequence]; local p=c.boss:get_location(); local q=player:get_location()
 if s.element==1 then s.zone=ground_circle(c,q,3)
 elseif s.element==2 then s.zone=forward_cone(c,p,q,8,3)
 else s.zone=forward_cone(c,p,q,12,.8) end
 s.fireAt=s.tick+28; c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,.5+s.element*.4)
end
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.order={1,2,3}; s.nextExposure=40; s.nextSequence=110
   player:send_message('&6Elementalist Instructor: &fFire gathers. Frost spreads. Lightning holds a narrow line.')
  end
  if s.fireAt then
   local color=colors[s.element]
   if s.tick%4==0 then show_circle(c,s.zone,color[1],color[2],color[3]) end
   if s.tick>=s.fireAt then
    c.script:damage(s.zone:full_target(),1,s.empowered and .5 or .45)
    if s.element==2 then
     local p=player:get_location(); p.y=p.y+.75
     if s.zone:contains(p) then player:apply_potion_effect('SLOWNESS',20,0) end
    end
    s.fireAt=nil; s.betweenAt=s.tick+16
   end
   return
  end
  if s.betweenAt then
   if s.tick>=s.betweenAt then
    s.betweenAt=nil; s.sequence=s.sequence+1
    if s.sequence<=3 then prepare_element(c,player)
    else s.empowered=false; s.exposedUntil=s.tick+70; s.busyUntil=s.tick+70 end
   end
   return
  end
  if s.exposureAt then
   if s.tick%4==0 then c.boss:spawn_particle_at_self({particle='ENCHANT',amount=8},1) end
   if s.tick>=s.exposureAt then s.exposureAt=nil; s.empowered=true; s.busyUntil=s.tick+12 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.order={2,3,1}
   player:send_message('&6Elementalist Instructor: &fNow frost leads, lightning follows, and fire has the last word.')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  if s.tick>=s.nextExposure then
   s.nextExposure=s.tick+480; s.exposureAt=s.tick+32; pause_movement(c,44)
  elseif s.tick>=s.nextSequence then
   s.nextSequence=s.tick+520; s.sequence=1; prepare_element(c,player); pause_movement(c,202)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Elementalist Instructor: &fYou read each element on its own terms. Keep that patience.',24) end
}
