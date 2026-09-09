-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- A scattered choir heals poorly. The bell gives the attendants a brief burst
-- of speed, while the stationary chorus gives the challenger an interrupt window.
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.attendants={}
  for i=1,3 do
   local ally=c.world:spawn_custom_boss_at_location('class_trial_priest_attendant.yml',
    {world=p.world,x=p.x+(i-2)*3,y=p.y,z=p.z+3},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(ally,'Shepherd attendant could not spawn'); table.insert(c.state.attendants,ally)
  end
  c.state.healingLeft=c.boss:get_maximum_health()*.18
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextGather=50; s.nextChorus=200
   player:send_message('&6Shepherd Instructor: &fListen for the bell. Three close voices carry farther than one.')
  end
  if s.gatherAt or (s.gatherUntil or 0)>s.tick then
   if s.tick%6==0 then
    for _,ally in ipairs(s.attendants) do if ally:is_alive() then cleric_tether(c,c.boss,ally,false) end end
   end
  end
  if s.gatherAt then
   if s.tick>=s.gatherAt then
    s.gatherAt=nil; s.gatherUntil=s.tick+60; s.restUntil=s.tick+40
    for _,ally in ipairs(s.attendants) do if ally:is_alive() then ally:apply_potion_effect('SPEED',60,0) end end
    c.boss:play_sound_at_self('BLOCK_BELL_USE',.7,1.2)
   end
   return
  end
  if s.chorusAt then
   if s.tick%4==0 then show_circle(c,s.chorus,245,220,150) end
   if s.tick>=s.chorusAt then
    local count=0
    for _,ally in ipairs(s.attendants) do if cleric_in_circle(ally,s.anchor,5) then count=count+1 end end
    for _,ally in ipairs(s.attendants) do if cleric_in_circle(ally,s.anchor,5) then cleric_heal(c,ally,.1*count) end end
    s.chorusAt=nil; s.restUntil=s.tick+60
    c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.6,.8+count*.2)
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; local farthest,distance=nil,-1; local p=c.boss:get_location()
   for _,ally in ipairs(s.attendants) do
    if ally:is_alive() then
     local q=ally:get_location(); local d=(p.x-q.x)^2+(p.z-q.z)^2
     if d>distance then farthest=ally; distance=d end
    end
   end
   player:send_message('&6Shepherd Instructor: &fA shepherd notices the one farthest away.')
   if farthest and radiant_flight(c,farthest:get_location()) then s.restUntil=s.tick+60; return end
  end
  if s.tick>=s.nextGather then
   s.nextGather=s.tick+440; s.gatherAt=s.tick+32; c.boss:set_ai_enabled(false)
   c.boss:play_sound_at_self('BLOCK_BELL_USE',.5,.8)
  elseif s.tick>=s.nextChorus and s.healingLeft>0 then
   s.nextChorus=s.tick+480; s.anchor=c.boss:get_location(); s.chorus=ground_circle(c,s.anchor,5)
   s.chorusAt=s.tick+40; s.channelDamage=0; c.boss:set_ai_enabled(false)
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.6,.7)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if not s.chorusAt or c.event.is_damage_transfer then return end
  s.channelDamage=s.channelDamage+c.event.get_damage_amount()
  if s.channelDamage>=c.boss:get_maximum_health()*.025 then
   s.chorusAt=nil; s.restUntil=s.tick+60
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.5)
   c.boss:send_message('&6Shepherd Instructor: &fThe choir lost its lead. You heard the opening.',24)
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer or (s.gatherUntil or 0)<=(s.tick or 0) then return end
  for _,ally in ipairs(s.attendants or {}) do
   if c.event.entity.uuid==ally.uuid then c.event.multiply_damage_amount(.75); return end
  end
 end,
 on_death=function(c)
  c.boss:send_message('&6Shepherd Instructor: &fYou listened, and you chose. Take care of those who follow you.',24)
 end
}
