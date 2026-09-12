-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- The seed waits until a heavy hit actually lowers health, then shelters the
-- following attacks. Renewing Bond breaks after sustained separation.
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.attendant=c.world:spawn_custom_boss_at_location('class_trial_shaman_attendant.yml',
   {world=p.world,x=p.x+3,y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.attendant,'Lifewarden attendant could not spawn')
  c.state.healingLeft=c.boss:get_maximum_health()*.15
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextBond=50; s.nextSeed=230
   player:send_message('&6Lifewarden Instructor: &fThe bond has a reach. The seed answers after the wound.')
  end
  if s.seedPending then
   if s.attendant:is_alive() and s.attendant:get_health()<s.seedPending then
    s.seedUntil=0; s.shield=s.attendant:get_maximum_health()*.25; s.shieldUntil=s.tick+100
    s.attendant:spawn_particle_at_self({particle='HAPPY_VILLAGER',amount=8},1)
   end
   s.seedPending=nil
  end
  if (s.shieldUntil or 0)<=s.tick then s.shield=0 end
  if s.attendant:is_alive() and ((s.seedUntil or 0)>s.tick or (s.shield or 0)>0) and s.tick%6==0 then
   s.attendant:spawn_particle_at_self({particle='COMPOSTER',amount=4},1)
  end
  if (s.bondUntil or 0)>s.tick then
   local linked=cleric_in_circle(s.attendant,c.boss:get_location(),7)
   s.separated=linked and 0 or (s.separated or 0)+1
   if s.separated>=20 then
    s.bondUntil=0
    player:send_message('&6Lifewarden Instructor: &fThe bond has been stretched beyond its reach.')
   elseif linked then
    if s.tick%5==0 then cleric_tether(c,c.boss,s.attendant,true) end
    if s.tick%30==0 then cleric_heal(c,s.attendant,.06) end
   end
  end
  if s.castAt then
   if s.attendant:is_alive() and s.tick%4==0 then cleric_tether(c,c.boss,s.attendant,true) end
   if s.tick>=s.castAt then
    if s.castingSeed then s.seedUntil=s.tick+100 else s.bondUntil=s.tick+140; s.separated=0 end
    s.castAt=nil; s.restUntil=s.tick+30
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Lifewarden Instructor: &fI will close the distance. Find room to stretch the bond again.')
   if s.attendant:is_alive() and radiant_flight(c,s.attendant:get_location()) then s.restUntil=s.tick+60; return end
  end
  if not s.attendant:is_alive() then return end
  if s.tick>=s.nextBond and s.healingLeft>0 then
   s.nextBond=s.tick+440; s.castingSeed=false; s.castAt=s.tick+32
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_AZALEA_LEAVES_PLACE',.6,1.2)
  elseif s.tick>=s.nextSeed then
   s.nextSeed=s.tick+480; s.castingSeed=true; s.castAt=s.tick+36
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_CHORUS_FLOWER_GROW',.6,1.2)
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer or not s.attendant or c.event.entity.uuid~=s.attendant.uuid then return end
  local amount=c.event.get_damage_amount()
  if amount<=0 then return end
  if (s.shield or 0)>0 then
   local absorbed=math.min(s.shield,amount); s.shield=s.shield-absorbed
   c.event.multiply_damage_amount((amount-absorbed)/amount)
  elseif (s.seedUntil or 0)>(s.tick or 0) and not s.seedPending
    and amount>=s.attendant:get_maximum_health()*.15 then s.seedPending=s.attendant:get_health() end
 end,
 on_death=function(c)
  c.boss:send_message('&6Lifewarden Instructor: &fYou saw what sustained us, and what it could not reach.',24)
 end
}
