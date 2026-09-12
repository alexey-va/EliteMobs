-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc

-- Three narrow cuts lock separately. Warcasting grants a small finite ward;
-- the final cut spends it and leaves a longer, vulnerable recovery.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextWar=35; s.nextCuts=100
   player:send_message('&6Spellblade Instructor: &fThree cuts. Do not rush back in after the first.')
  end
  if (s.warUntil or 0)<=s.tick then s.ward=0 end
  if s.cutAt then
   if s.tick<s.cutAt-9 then s.zone=forward_cone(c,c.boss:get_location(),player:get_location(),5,.7) end
   if s.tick%3==0 then show_circle(c,s.zone,190,130,245) end
   if s.tick>=s.cutAt then
    c.script:damage(s.zone:full_target(),1,(s.warUntil or 0)>s.tick and .385 or .35)
    c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.6,.8+s.cut*.2)
    s.cut=s.cut+1
    if s.cut<=3 then s.cutAt=s.tick+16
    else s.cutAt=nil; s.ward=0; s.warUntil=0; s.busyUntil=s.tick+60; s.exposedUntil=s.busyUntil end
   end
   return
  end
  if s.warAt then
   if s.tick%4==0 then c.boss:spawn_particle_at_self({particle='ENCHANT',amount=8},1) end
   if s.tick>=s.warAt then
    s.warAt=nil; s.warUntil=s.tick+100; s.ward=c.boss:get_maximum_health()*.04; s.busyUntil=s.tick+12
    c.boss:apply_potion_effect('SPEED',60,0)
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Spellblade Instructor: &fA new angle, the same three beats. Keep your count.')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  if s.tick>=s.nextWar then
   s.nextWar=s.tick+440; s.warAt=s.tick+28; pause_movement(c,40)
   c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,.8)
  elseif s.tick>=s.nextCuts then
   s.nextCuts=s.tick+360; s.cut=1; s.cutAt=s.tick+30
   s.zone=forward_cone(c,c.boss:get_location(),player:get_location(),5,.7); pause_movement(c,122)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state; local amount=c.event.get_damage_amount()
  if (s.ward or 0)>0 and amount>0 then
   local used=math.min(amount,s.ward); s.ward=s.ward-used; c.event.multiply_damage_amount((amount-used)/amount)
  elseif (s.exposedUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Spellblade Instructor: &fYou let the last cut pass before answering. A disciplined hand.',24) end
}
