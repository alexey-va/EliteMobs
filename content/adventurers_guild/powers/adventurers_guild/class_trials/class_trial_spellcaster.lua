-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc
-- @include abilities/arcane_bolt.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextBolt=40; s.nextWard=180; s.nextBlink=300
   player:send_message('&6Spellcaster Instructor: &fWatch the aim settle. A spell is only dangerous where it lands.')
  end
  if (s.wardUntil or 0)<=s.tick then s.ward=0 end
  if (s.ward or 0)>0 and s.tick%6==0 then c.boss:spawn_particle_at_self({particle='ENCHANT',amount=8},1) end
  if s.fireAt then
   if s.tick<s.fireAt-10 then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then spell_aim(c,s.aim) end
   if s.tick>=s.fireAt then spell_bolt(c,s.aim,.7); s.fireAt=nil; s.busyUntil=s.tick+86 end
   return
  end
  if s.wardAt then
   if s.tick%4==0 then c.boss:spawn_particle_at_self({particle='ENCHANT',amount=6},1) end
   if s.tick>=s.wardAt then s.wardAt=nil; s.ward=c.boss:get_maximum_health()*.06; s.wardUntil=s.tick+80; s.busyUntil=s.tick+26 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.nextWard=s.tick
   player:send_message('&6Spellcaster Instructor: &fA ward has a limit. Decide whether to break it or let it fade.')
  end
  if s.tick>=s.nextWard then
   s.nextWard=s.tick+360; s.wardAt=s.tick+28; pause_movement(c,54)
   c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_RESONATE',.6,.8)
  elseif s.tick>=s.nextBlink then
   s.nextBlink=s.tick+300; if arcane_blink(c,player) then s.busyUntil=s.tick+46 end
  elseif s.tick>=s.nextBolt then
   s.nextBolt=s.tick+140; s.fireAt=s.tick+24; s.aim=player:get_eye_location(); pause_movement(c,110)
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.65) end end,
 on_boss_damaged_by_player=function(c)
  local s=c.state; local amount=c.event.get_damage_amount()
  if (s.ward or 0)>0 and amount>0 then
   local used=math.min(s.ward,amount); s.ward=s.ward-used; c.event.multiply_damage_amount((amount-used)/amount)
   if s.ward<=0 then
    s.exposedUntil=(s.tick or 0)+50; s.busyUntil=s.exposedUntil; pause_movement(c,50)
    c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.2)
   end
  elseif (s.exposedUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Spellcaster Instructor: &fYou chose your moment. That is the beginning of control.',24) end
}
