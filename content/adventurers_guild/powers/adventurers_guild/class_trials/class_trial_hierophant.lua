-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- Benediction rewards keeping three attendants near the instructor. Pressure
-- interrupts it and exposes the caster. Sacred Silence is a readable short
-- weakening pulse, using ordinary effects rather than a private ability lock.
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.attendants={}
  for i=1,3 do
   local ally=c.world:spawn_custom_boss_at_location('class_trial_priest_attendant.yml',
    {world=p.world,x=p.x+(i-2)*3,y=p.y,z=p.z+3},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(ally,'Hierophant attendant could not spawn'); table.insert(c.state.attendants,ally)
  end
  c.state.healingLeft=c.boss:get_maximum_health()*.18
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextBlessing=70; s.nextSilence=240
   player:send_message('&6Hierophant Instructor: &fThe blessing reaches those who stay together. You need not let us.')
  end
  if s.blessingAt then
   if s.tick%4==0 then show_circle(c,s.zone,245,220,150) end
   if s.tick>=s.blessingAt then
    for _,ally in ipairs(s.attendants) do
     if cleric_in_circle(ally,s.center,5) then cleric_heal(c,ally,.3) end
    end
    s.blessingAt=nil; s.restUntil=s.tick+60
    c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.6,1.5)
   end
   return
  end
  if s.silenceAt then
   if s.tick%4==0 then show_circle(c,s.zone,230,230,200) end
   if s.tick>=s.silenceAt then
    if s.zone:contains(player:get_location()) then player:apply_potion_effect('WEAKNESS',40,0) end
    s.silenceAt=nil; s.restUntil=s.tick+40
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Hierophant Instructor: &fI will follow those in need. Make your next opening count.')
   for _,ally in ipairs(s.attendants) do
    if ally:is_alive() and radiant_flight(c,ally:get_location()) then s.restUntil=s.tick+60; return end
   end
  end
  if s.tick>=s.nextBlessing and s.healingLeft>0 then
   s.nextBlessing=s.tick+480; s.center=c.boss:get_location(); s.zone=ground_circle(c,s.center,5)
   s.blessingAt=s.tick+46; s.channelDamage=0; c.boss:set_ai_enabled(false)
   c.boss:play_sound_at_self('BLOCK_BEACON_AMBIENT',.6,1.2)
  elseif s.tick>=s.nextSilence then
   s.nextSilence=s.tick+400; s.zone=ground_circle(c,c.boss:get_location(),3); s.silenceAt=s.tick+30
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_BELL_USE',.6,.8)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer then return end
  if (s.exposedUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.2) end
  if not s.blessingAt then return end
  s.channelDamage=s.channelDamage+c.event.get_damage_amount()
  if s.channelDamage>=c.boss:get_maximum_health()*.025 then
   s.blessingAt=nil; s.restUntil=s.tick+60; s.exposedUntil=s.restUntil
   c.boss:send_message('&6Hierophant Instructor: &fWell placed. Even a blessing needs a quiet moment.',24)
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.4)
  end
 end,
 on_death=function(c)
  c.boss:send_message('&6Hierophant Instructor: &fYou understood the gathering, and the space between its members.',24)
 end
}
