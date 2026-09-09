-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- Life Current breaks after one second of separation. Spirit Totem is a normal
-- destructible reinforcement; its fixed healing ground invites a target switch.
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.attendant=c.world:spawn_custom_boss_at_location('class_trial_shaman_attendant.yml',
   {world=p.world,x=p.x+3,y=p.y,z=p.z+1},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.attendant,'Shaman attendant could not spawn')
  c.state.healingLeft=c.boss:get_maximum_health()*.15
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextCurrent=80; s.nextTotem=200
   player:send_message('&6Shaman Instructor: &fA current needs a path. Draw us apart, and watch the totem.')
  end
  if s.currentUntil and s.tick<s.currentUntil then
   local linked=cleric_in_circle(s.attendant,c.boss:get_location(),6)
   s.separated=linked and 0 or (s.separated or 0)+1
   if s.separated>=20 then
    s.currentUntil=nil
    player:send_message('&6Shaman Instructor: &fThe current cannot reach that far. Well read.')
   elseif linked then
    if s.tick%5==0 then cleric_tether(c,c.boss,s.attendant,true) end
    if s.tick%20==0 then cleric_heal(c,s.attendant,.06) end
   end
  end
  if s.totem then
   if not s.totem:is_alive() or s.tick>=s.totemUntil then
    if s.totem:is_alive() then s.totem:remove_elite() end
    s.totem=nil; c.boss:play_sound_at_self('BLOCK_WOOD_BREAK',.5,1)
   else
    if s.tick%5==0 then show_circle(c,s.totemZone,85,220,245) end
    if s.tick%40==0 then
     if cleric_in_circle(s.attendant,s.totemPosition,4) then cleric_heal(c,s.attendant,.08) end
     if cleric_in_circle(c.boss,s.totemPosition,4) then cleric_heal(c,c.boss,.0075) end
    end
   end
  end
  if s.currentAt then
   if s.attendant:is_alive() and s.tick%5==0 then cleric_tether(c,c.boss,s.attendant,true) end
   if s.tick>=s.currentAt then
    s.currentAt=nil; s.currentUntil=s.tick+120; s.separated=0; s.restUntil=s.tick+30
   end
   return
  end
  if s.totemAt then
   if s.tick%4==0 then show_circle(c,s.totemZone,85,220,245) end
   if s.tick>=s.totemAt then
    s.totemAt=nil
    s.totem=c.world:spawn_custom_boss_at_location('class_trial_spirit_totem.yml',s.totemPosition,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.totem,'Spirit Totem could not spawn')
    s.totemUntil=s.tick+140; s.restUntil=s.tick+30
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Shaman Instructor: &fThe spirits gather where we stand. Choose that ground with care.')
   local anchor=s.totem and s.totem:get_location() or s.attendant:is_alive() and s.attendant:get_location()
   if radiant_flight(c,anchor) then s.restUntil=s.tick+60; return end
  end
  if s.healingLeft<=0 then return end
  if s.tick>=s.nextTotem and not s.totem then
   s.nextTotem=s.tick+480
   local p=c.boss:get_location(); s.totemPosition={world=p.world,x=p.x+1.5,y=p.y,z=p.z}
   s.totemZone=ground_circle(c,s.totemPosition,4); s.totemAt=s.tick+36
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_WOOD_PLACE',.6,1.2)
  elseif s.tick>=s.nextCurrent and s.attendant:is_alive() then
   s.nextCurrent=s.tick+400; s.currentAt=s.tick+30
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_CONDUIT_AMBIENT_SHORT',.6,1.3)
  end
 end,
 on_death=function(c)
  c.boss:send_message('&6Shaman Instructor: &fYou listened to the current and chose your footing. The spirits heard.',24)
 end
}
