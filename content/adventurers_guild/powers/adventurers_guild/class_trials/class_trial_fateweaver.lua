-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- A single visible knot rescues one endangered attendant. The challenger can
-- change targets or wait it out. Prophecy separately softens one heavy hit.
local function weakest(c)
 local chosen
 for _,ally in ipairs(c.state.attendants) do
  if ally:is_alive() and (not chosen or ally:get_health()/ally:get_maximum_health()
    <chosen:get_health()/chosen:get_maximum_health()) then chosen=ally end
 end
 return chosen
end
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.attendants={}
  for i=1,2 do
   local ally=c.world:spawn_custom_boss_at_location('class_trial_fate_attendant.yml',
    {world=p.world,x=p.x+(i==1 and -3 or 3),y=p.y,z=p.z+2},
    {level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(ally,'Fateweaver attendant could not spawn')
   table.insert(c.state.attendants,ally)
  end
  c.state.healingLeft=c.boss:get_maximum_health()*.12
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextProphecy=230
   player:send_message('&6Fateweaver Instructor: &fOne golden thread can be rewritten. The others remain yours to choose.')
  end
  if s.knot and s.knot:is_alive() and (s.knotUntil or 0)>s.tick and s.tick%5==0 then
   cleric_tether(c,c.boss,s.knot,false)
   s.knot:spawn_particle_at_self({particle='END_ROD',amount=3},1)
  end
  if s.predicted and s.predicted:is_alive() and (s.prophecyUntil or 0)>s.tick and s.tick%8==0 then
   s.predicted:spawn_particle_at_self({particle='ENCHANT',amount=6},1)
  end
  if s.castAt then
   if s.recipient:is_alive() and s.tick%4==0 then cleric_tether(c,c.boss,s.recipient,false) end
   if s.tick>=s.castAt then
    if s.castingKnot then s.knot=s.recipient; s.knotUntil=s.tick+120
    else s.predicted=s.recipient; s.prophecyUntil=s.tick+100 end
    s.castAt=nil; s.restUntil=s.tick+50
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  local ally=weakest(c)
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Fateweaver Instructor: &fA different thread. Do not mistake foresight for certainty.')
   if ally and radiant_flight(c,ally:get_location()) then s.restUntil=s.tick+60; return end
  end
  if not s.rewriteUsed and ally then
   s.rewriteUsed=true; s.recipient=ally; s.castingKnot=true; s.castAt=s.tick+40; s.channelDamage=0
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_BEACON_AMBIENT',.6,1.4)
  elseif s.tick>=s.nextProphecy and ally then
   s.nextProphecy=s.tick+440; s.recipient=ally; s.castingKnot=false; s.castAt=s.tick+32; s.channelDamage=0
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,1.2)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if not s.castAt or c.event.is_damage_transfer then return end
  s.channelDamage=s.channelDamage+c.event.get_damage_amount()
  if s.channelDamage>=c.boss:get_maximum_health()*.025 then
   s.castAt=nil; s.restUntil=s.tick+50
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.5)
   c.boss:send_message('&6Fateweaver Instructor: &fThe thread slipped. You made that opening.',24)
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer then return end
  local amount=c.event.get_damage_amount()
  if amount<=0 then return end
  if s.knot and c.event.entity.uuid==s.knot.uuid and (s.knotUntil or 0)>(s.tick or 0)
    and (s.knot:get_health()<=s.knot:get_maximum_health()*.35 or amount>=s.knot:get_health()) then
   s.knotUntil=0; c.event.cancel_event(); cleric_heal(c,s.knot,.3)
   c.boss:play_sound_at_self('ITEM_TOTEM_USE',.6,1.3)
   c.boss:send_message('&6Fateweaver Instructor: &fOne thread rewritten. The knot is spent.',24)
  elseif s.predicted and c.event.entity.uuid==s.predicted.uuid
    and (s.prophecyUntil or 0)>(s.tick or 0) and amount>=s.predicted:get_maximum_health()*.12 then
   s.prophecyUntil=0; c.event.multiply_damage_amount(.5)
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.5,.7)
  end
 end,
 on_death=function(c)
  c.boss:send_message('&6Fateweaver Instructor: &fYou found the choices the vision could not make for you.',24)
 end
}
