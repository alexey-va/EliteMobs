-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- Breaking Foreseen Rescue spends the shield and opens the instructor; waiting
-- it out avoids its heal. Foresight catches only the next hit, not every attack.
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.attendant=c.world:spawn_custom_boss_at_location('class_trial_oracle_attendant.yml',
   {world=p.world,x=p.x+3,y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.attendant,'Oracle attendant could not spawn')
  c.state.healingLeft=c.boss:get_maximum_health()*.1
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextRescue=60; s.nextForesight=230
   player:send_message('&6Oracle Instructor: &fA rescue has a cost. Break the light, or let its moment pass.')
  end
  if s.shieldUntil and s.tick>=s.shieldUntil then s.shield=0; s.shieldUntil=nil end
  if (s.shield or 0)>0 and s.attendant:is_alive() and s.tick%5==0 then
   cleric_tether(c,c.boss,s.attendant,false)
   s.attendant:spawn_particle_at_self({particle='END_ROD',amount=3},1)
  end
  if (s.foresightUntil or 0)>s.tick and s.tick%8==0 then
   c.boss:spawn_particle_at_self({particle='ENCHANT',amount=6},1)
  end
  if s.rescueAt then
   if s.attendant:is_alive() and s.tick%4==0 then cleric_tether(c,c.boss,s.attendant,false) end
   if s.tick>=s.rescueAt then
    s.rescueAt=nil; s.shield=s.attendant:get_maximum_health()*.3
    s.shieldUntil=s.tick+100; s.restUntil=s.tick+40
   end
   return
  end
  if s.foresightAt then
   if s.tick%4==0 then c.boss:spawn_particle_at_self({particle='ENCHANT',amount=4},1) end
   if s.tick>=s.foresightAt then
    s.foresightAt=nil; s.foresightUntil=s.tick+80; s.restUntil=s.tick+30
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Oracle Instructor: &fKnowing an opening is not the same as reaching it.')
   if s.attendant:is_alive() and radiant_flight(c,s.attendant:get_location()) then s.restUntil=s.tick+60; return end
  end
  if s.tick>=s.nextRescue and s.attendant:is_alive() then
   s.nextRescue=s.tick+440; s.rescueAt=s.tick+36
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.6,1.4)
  elseif s.tick>=s.nextForesight then
   s.nextForesight=s.tick+400; s.foresightAt=s.tick+30
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,1.2)
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer or not s.attendant or c.event.entity.uuid~=s.attendant.uuid
   or (s.shield or 0)<=0 then return end
  local incoming=c.event.get_damage_amount()
  if incoming<=0 then return end
  local absorbed=math.min(s.shield,incoming)
  s.shield=s.shield-absorbed
  c.event.multiply_damage_amount((incoming-absorbed)/incoming)
  if s.shield<=0 then
   cleric_heal(c,s.attendant,.15); s.exposedUntil=s.tick+50
   c.boss:send_message('&6Oracle Instructor: &fYou chose to break it. The opening is yours.',24)
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.6,1.2)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer then return end
  if (s.exposedUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.25)
  elseif (s.foresightUntil or 0)>(s.tick or 0) and c.event.get_damage_amount()>0 then
   s.foresightUntil=nil; c.event.multiply_damage_amount(.5)
  end
 end,
 on_death=function(c)
  c.boss:send_message('&6Oracle Instructor: &fYou chose well when the future offered more than one answer.',24)
 end
}
