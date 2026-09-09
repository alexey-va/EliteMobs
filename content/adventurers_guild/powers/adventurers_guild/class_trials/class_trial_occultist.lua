-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc
-- @include abilities/arcane_bolt.inc

-- Sight marks the next cast. The lance locks fourteen ticks before release;
-- recovery is fixed, so no private projectile hit-receipt system is needed.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextSight=35; s.nextLance=100
   player:send_message('&6Occultist Instructor: &fBeing seen is not the same as being struck. Wait for the aim to settle.')
  end
  if (s.sightUntil or 0)>s.tick and s.tick%8==0 then player:spawn_particle_at_self({particle='ENCHANT',amount=3},1) end
  if s.sightAt then
   if s.tick%4==0 then c.boss:spawn_particle_at_self({particle='ENCHANT',amount=6},1) end
   if s.tick>=s.sightAt then s.sightAt=nil; s.sightUntil=s.tick+120; s.busyUntil=s.tick+12 end
   return
  end
  if s.lanceAt then
   if s.tick<s.lanceAt-14 then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%3==0 then spell_aim(c,s.aim) end
   if s.tick>=s.lanceAt then
    spell_bolt(c,s.aim,1.2); s.lanceAt=nil; s.sightUntil=0; s.busyUntil=s.tick+120; s.exposedUntil=s.busyUntil
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Occultist Instructor: &fAnother angle. Let us see whether you learned the first lesson.')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  if s.tick>=s.nextSight then
   s.nextSight=s.tick+440; s.sightAt=s.tick+30; pause_movement(c,42)
   c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,.6)
  elseif s.tick>=s.nextLance then
   s.nextLance=s.tick+360; s.lanceAt=s.tick+36; s.aim=player:get_eye_location()
   s.lanceDamage=(s.sightUntil or 0)>s.tick and .99 or .9; pause_movement(c,156)
  end
 end,
 on_player_damaged_by_boss=function(c)
  if c.event.projectile then
   c.event.multiply_damage_amount(c.state.lanceDamage or .9)
   local player=c.boss:get_target_player(); if player then player:apply_potion_effect('WEAKNESS',40,0) end
  end
 end,
 on_boss_damaged_by_player=function(c)
  if (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Occultist Instructor: &fObservation, then action. You may yet learn something here.',24) end
}
