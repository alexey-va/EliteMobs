-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- An ancestral focus repeats the first heal after three seconds. It can be
-- destroyed, or its recipient pulled outside the marked circle before the echo.
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.attendants={}; c.state.links={}
  for i=1,2 do
   local ally=c.world:spawn_custom_boss_at_location('class_trial_shaman_attendant.yml',
    {world=p.world,x=p.x+(i==1 and -3 or 3),y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(ally,'Spiritcaller attendant could not spawn'); table.insert(c.state.attendants,ally)
  end
  c.state.healingLeft=c.boss:get_maximum_health()*.18
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextEcho=60; s.nextLink=220
   player:send_message('&6Spiritcaller Instructor: &fThe first prayer leaves an echo. You may quiet it before it answers.')
  end
  if s.focus then
   if not s.focus:is_alive() or s.tick>=s.echoAt then
    if s.focus:is_alive() then
     if cleric_in_circle(s.recipient,s.anchor,5) then cleric_heal(c,s.recipient,.15) end
     s.focus:remove_elite()
    end
    s.focus=nil
   elseif s.tick%5==0 then
    show_circle(c,s.echoCircle,85,220,245)
    if s.recipient:is_alive() then cleric_tether(c,s.focus,s.recipient,true) end
   end
  end
  if (s.linkUntil or 0)>s.tick then
   for i,ally in ipairs(s.attendants) do
    if s.links[i] then
     if not cleric_in_circle(ally,c.boss:get_location(),7) then
      s.links[i]=false; player:send_message('&6Spiritcaller Instructor: &fThat thread can carry no more.')
     elseif s.tick%5==0 then cleric_tether(c,c.boss,ally,true) end
    end
   end
  end
  if s.castAt then
   if s.tick%4==0 then
    for _,ally in ipairs(s.attendants) do if ally:is_alive() then cleric_tether(c,c.boss,ally,true) end end
   end
   if s.tick>=s.castAt then
    if s.castingEcho then
     if s.recipient:is_alive() then
      cleric_heal(c,s.recipient,.3)
      s.focus=c.world:spawn_custom_boss_at_location('class_trial_ancestral_echo.yml',s.anchor,
       {level=c.boss.level,add_as_reinforcement=true,silent=true})
      assert(s.focus,'Ancestral Echo could not spawn'); s.echoAt=s.tick+60
     end
     s.restUntil=s.tick+50
    else
     s.linkUntil=s.tick+120
     for i,ally in ipairs(s.attendants) do s.links[i]=cleric_in_circle(ally,c.boss:get_location(),7) end
     s.restUntil=s.tick+30
    end
    s.castAt=nil
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Spiritcaller Instructor: &fWe move on. The echo must stay behind.')
   local p=c.boss:get_location(); local q=player:get_location(); local dx,dz=q.x-p.x,q.z-p.z
   local d=math.sqrt(dx*dx+dz*dz)
   if d>.01 and radiant_flight(c,{world=p.world,x=p.x-dz/d*4,y=p.y,z=p.z+dx/d*4}) then s.restUntil=s.tick+60; return end
  end
  if s.tick>=s.nextEcho and not s.focus and s.healingLeft>0 then
   s.nextEcho=s.tick+480; s.recipient=nil
   for _,ally in ipairs(s.attendants) do
    if ally:is_alive() and (not s.recipient or ally:get_health()/ally:get_maximum_health()<s.recipient:get_health()/s.recipient:get_maximum_health()) then s.recipient=ally end
   end
   if s.recipient then
    s.anchor=c.boss:get_location(); s.echoCircle=ground_circle(c,s.anchor,5)
    s.castingEcho=true; s.castAt=s.tick+40; s.channelDamage=0; c.boss:set_ai_enabled(false)
    c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,.9)
   end
  elseif s.tick>=s.nextLink then
   s.nextLink=s.tick+440; s.castingEcho=false; s.castAt=s.tick+32; c.boss:set_ai_enabled(false)
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.6,1.3)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if not s.castAt or not s.castingEcho or c.event.is_damage_transfer then return end
  s.channelDamage=s.channelDamage+c.event.get_damage_amount()
  if s.channelDamage>=c.boss:get_maximum_health()*.025 then
   s.castAt=nil; s.restUntil=s.tick+50
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.5)
   c.boss:send_message('&6Spiritcaller Instructor: &fA prayer unspoken leaves no echo.',24)
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer or (s.linkUntil or 0)<=(s.tick or 0) then return end
  for i,ally in ipairs(s.attendants or {}) do
   if s.links[i] and c.event.entity.uuid==ally.uuid and cleric_in_circle(ally,c.boss:get_location(),7) then
    if c.event:transfer_damage(c.boss,c.event.get_damage_amount()*.3) then c.event.multiply_damage_amount(.7) end
    return
   end
  end
 end,
 on_death=function(c)
  c.boss:send_message('&6Spiritcaller Instructor: &fYou knew which voice to follow, and which to let fade.',24)
 end
}
