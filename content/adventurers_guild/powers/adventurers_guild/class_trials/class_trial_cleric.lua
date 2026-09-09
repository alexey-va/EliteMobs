-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- Interrupt Mend or draw the pair out of Sanctuary. Healing cannot extend the
-- encounter indefinitely: all healing spends one finite allowance.
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.acolyte=c.world:spawn_custom_boss_at_location('class_trial_cleric_acolyte.yml',
   {world=p.world,x=p.x+3,y=p.y,z=p.z+1},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.acolyte,'Cleric acolyte could not spawn')
  c.state.healingLeft=c.boss:get_maximum_health()*.12
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextMend=100; s.nextSanctuary=40
   player:send_message('&6Cleric Instructor: &fWatch the light. Draw us out, or interrupt the prayer.')
  end
  if s.sanctuaryUntil and s.tick<s.sanctuaryUntil then
   if s.tick%5==0 then show_circle(c,s.sanctuaryZone,245,220,150) end
   if s.tick%20==0 then
    if cleric_in_circle(c.boss,s.sanctuary,3.5) then cleric_heal(c,c.boss,.005) end
    if cleric_in_circle(s.acolyte,s.sanctuary,3.5) then cleric_heal(c,s.acolyte,.05) end
   end
  end
  if s.mendAt then
   if s.recipient:is_alive() and s.tick%4==0 then cleric_tether(c,c.boss,s.recipient,false) end
   if s.tick>=s.mendAt then
    cleric_heal(c,s.recipient,s.recipient.uuid==c.boss.uuid and .02 or .2)
    s.mendAt=nil; s.restUntil=s.tick+40
    c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.6,1.3)
   end
   return
  end
  if s.sanctuaryAt then
   if s.tick%4==0 then show_circle(c,s.sanctuaryZone,245,220,150) end
   if s.tick>=s.sanctuaryAt then
    s.sanctuaryAt=nil; s.sanctuaryUntil=s.tick+120; s.restUntil=s.tick+30
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Cleric Instructor: &fAn ally is an anchor. Keep sight of both of us.')
   local anchor=s.acolyte:is_alive() and s.acolyte:get_location() or s.sanctuary
   if radiant_flight(c,anchor) then s.restUntil=s.tick+60; return end
  end
  if s.healingLeft<=0 then return end
  if s.tick>=s.nextSanctuary then
   s.nextSanctuary=s.tick+400; s.sanctuary=c.boss:get_location()
   s.sanctuaryZone=ground_circle(c,s.sanctuary,3.5); s.sanctuaryAt=s.tick+30
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,1.3)
  elseif s.tick>=s.nextMend then
   s.nextMend=s.tick+280; s.recipient=s.acolyte:is_alive() and s.acolyte or c.boss
   s.mendAt=s.tick+40; s.channelDamage=0
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_BEACON_AMBIENT',.6,1.2)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if not s.mendAt or c.event.is_damage_transfer then return end
  s.channelDamage=s.channelDamage+c.event.get_damage_amount()
  if s.channelDamage>=c.boss:get_maximum_health()*.025 then
   s.mendAt=nil; s.restUntil=s.tick+40
   c.boss:set_ai_enabled(false)
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.5)
   c.boss:send_message('&6Cleric Instructor: &fWell timed. The prayer can wait.',24)
  end
 end,
 on_death=function(c)
  c.boss:send_message('&6Cleric Instructor: &fYou saw the whole fight, not just the person before you. That is the gift.',24)
 end
}
