-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextGuard=40; s.nextCleave=100
   player:send_message('&6Battlemage Instructor: &fThe blade feeds the ward only if it finds you. Keep outside the sweep.')
  end
  if (s.wardUntil or 0)<=s.tick then s.ward=0 end
  if (s.guardUntil or 0)>s.tick and (s.guardHits or 0)>0 and s.tick%6==0 then c.boss:spawn_particle_at_self({particle='ENCHANT',amount=6},1) end
  if s.cleaveAt then
   if s.tick<s.cleaveAt-12 then s.zone=forward_cone(c,c.boss:get_location(),player:get_location(),4,2.5) end
   if s.tick%4==0 then show_circle(c,s.zone,170,120,245) end
   if s.tick>=s.cleaveAt then
    s.cleaving=true; c.script:damage(s.zone:full_target(),1,.85); s.cleaving=false
    s.cleaveAt=nil; s.busyUntil=s.tick+56; c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.6,.8)
   end
   return
  end
  if s.guardAt then
   if s.tick%4==0 then c.boss:spawn_particle_at_self({particle='ENCHANT',amount=6},1) end
   if s.tick>=s.guardAt then s.guardAt=nil; s.guardHits=2; s.guardUntil=s.tick+80; s.busyUntil=s.tick+20 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Battlemage Instructor: &fTwo guarded blows. Count them, then commit.')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  if s.tick>=s.nextGuard then
   s.nextGuard=s.tick+400; s.guardAt=s.tick+28; pause_movement(c,48)
   c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_RESONATE',.6,1.1)
  elseif s.tick>=s.nextCleave then
   s.nextCleave=s.tick+320; s.cleaveAt=s.tick+30
   s.zone=forward_cone(c,c.boss:get_location(),player:get_location(),4,2.5); pause_movement(c,86)
  end
 end,
 on_player_damaged_by_boss=function(c)
  if c.state.cleaving and c.event.get_damage_amount()>0 then
   c.state.ward=c.boss:get_maximum_health()*.04; c.state.wardUntil=c.state.tick+60
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state; local amount=c.event.get_damage_amount(); if amount<=0 then return end
  if (s.ward or 0)>0 then
   local used=math.min(amount,s.ward); s.ward=s.ward-used; c.event.multiply_damage_amount((amount-used)/amount)
  elseif (s.guardUntil or 0)>(s.tick or 0) and (s.guardHits or 0)>0 then
   s.guardHits=s.guardHits-1; c.event.multiply_damage_amount(.6)
   if s.guardHits==0 then
    s.exposedUntil=(s.tick or 0)+50; s.busyUntil=s.exposedUntil; s.cleaveAt=nil; pause_movement(c,50)
    c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.6,1.2)
   end
  elseif (s.exposedUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Battlemage Instructor: &fSteel and spell both need an opening. You found ours.',24) end
}
