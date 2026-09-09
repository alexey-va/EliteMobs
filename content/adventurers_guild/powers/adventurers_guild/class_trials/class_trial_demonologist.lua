-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc
-- @include abilities/arcane_bolt.inc

-- The gate anchor exists throughout the summoning channel and can be destroyed.
-- A finite native blaze is protected by a pact that exposes its instructor.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.charges=2; s.nextGate=45; s.nextPact=0; s.nextBolt=180
   player:send_message('&6Demonologist Instructor: &fAn invitation can be withdrawn. Break the anchor before something answers.')
  end
  if s.servitor and (not s.servitor:is_alive() or s.tick>=s.servitorUntil) then
   if s.servitor:is_alive() then s.servitor:remove_elite() end
   s.servitor=nil; s.pactUntil=0; s.pactAt=nil
  end
  if (s.pactUntil or 0)>s.tick and s.tick%6==0 then
   c.boss:spawn_particle_at_self({particle='SOUL_FIRE_FLAME',amount=5},1)
   if s.servitor then s.servitor:spawn_particle_at_self({particle='ENCHANT',amount=5},1) end
  end
  if s.gateAt then
   if not s.anchor:is_alive() then
    s.gateAt=nil; s.anchor=nil; s.busyUntil=s.tick+60; pause_movement(c,60)
    player:send_message('&6Demonologist Instructor: &fThe invitation is ruined. That one will not answer.')
   else
    if s.tick%4==0 then show_circle(c,s.marker,230,90,80) end
    if s.tick>=s.gateAt then
     s.gateAt=nil; local p=s.anchor:get_location(); s.anchor:remove_elite(); s.anchor=nil
     s.servitor=c.world:spawn_custom_boss_at_location('class_trial_nether_servitor.yml',p,
      {level=c.boss.level,add_as_reinforcement=true,silent=true})
     assert(s.servitor,'Nether Servitor could not spawn'); s.servitorUntil=s.tick+200; s.busyUntil=s.tick+50
    end
   end
   return
  end
  if s.pactAt then
   if s.tick%4==0 then c.boss:spawn_particle_at_self({particle='SOUL_FIRE_FLAME',amount=5},1) end
   if s.tick>=s.pactAt then s.pactAt=nil; s.pactUntil=s.tick+100; s.busyUntil=s.tick+60 end
   return
  end
  if s.boltAt then
   if s.tick%4==0 then spell_aim(c,s.aim) end
   if s.tick>=s.boltAt then spell_bolt(c,s.aim,.75); s.boltAt=nil; s.busyUntil=s.tick+80 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Demonologist Instructor: &fEvery pact has a price. Mine is now rather visible.')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  if not s.servitor and s.charges>0 and s.tick>=s.nextGate then
   s.charges=s.charges-1; s.nextGate=s.tick+560; local p=c.boss:get_location()
   local location={world=p.world,x=p.x-3,y=p.y,z=p.z+3}
   s.anchor=c.world:spawn_custom_boss_at_location('class_trial_nether_gate_anchor.yml',location,
    {level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(s.anchor,'Nether Gate Anchor could not spawn'); s.marker=ground_circle(c,location,1.3)
   s.gateAt=s.tick+46; pause_movement(c,96); c.boss:play_sound_at_self('BLOCK_RESPAWN_ANCHOR_CHARGE',.6,.7)
  elseif s.servitor and s.tick>=s.nextPact then
   s.nextPact=s.tick+440; s.pactAt=s.tick+36; pause_movement(c,96)
   c.boss:play_sound_at_self('BLOCK_RESPAWN_ANCHOR_CHARGE',.6,1.2)
  elseif s.tick>=s.nextBolt then
   s.nextBolt=s.tick+180; s.boltAt=s.tick+30; s.aim=player:get_eye_location(); pause_movement(c,110)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if (c.state.pactUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.25) end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if s.servitor and c.event.entity.uuid==s.servitor.uuid and (s.pactUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(.65) end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.3) end end,
 on_death=function(c) c.boss:send_message('&6Demonologist Instructor: &fYou read the price before paying it. An uncommon talent.',24) end
}
