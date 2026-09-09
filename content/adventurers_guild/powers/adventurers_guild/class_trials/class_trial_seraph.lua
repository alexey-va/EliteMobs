-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- Mercy must travel through a continuous five-block chain. Ascension protects
-- one attendant by sharing damage with the instructor, never making it immune.
local function chain_order(c)
 local result={}
 for i=1,#c.state.attendants do
  result[i]=c.state.attendants[c.state.phaseTwo and #c.state.attendants-i+1 or i]
 end
 return result
end
local function draw_chain(c,order)
 local previous=c.boss
 for _,ally in ipairs(order) do
  if not cleric_in_circle(ally,previous:get_location(),5) then break end
  cleric_tether(c,previous,ally,false); previous=ally
 end
end
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.attendants={}
  for i=1,3 do
   local ally=c.world:spawn_custom_boss_at_location('class_trial_seraph_attendant.yml',
    {world=p.world,x=p.x+(i-2)*3,y=p.y,z=p.z+3},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(ally,'Seraph attendant could not spawn')
   table.insert(c.state.attendants,ally)
  end
  c.state.healingLeft=c.boss:get_maximum_health()*.18
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextChain=80; s.nextAscend=240
   player:send_message('&6Seraph Instructor: &fMercy passes from hand to hand. A gap can stop the whole prayer.')
  end
  if s.lifted and (s.liftUntil or 0)>s.tick and cleric_in_circle(s.lifted,c.boss:get_location(),6) and s.tick%5==0 then
   cleric_tether(c,c.boss,s.lifted,false)
   s.lifted:spawn_particle_at_self({particle='END_ROD',amount=2},1)
  end
  if s.chainAt then
   if s.tick%4==0 then draw_chain(c,s.order) end
   if s.tick>=s.chainAt then
    local previous=c.boss
    for i,ally in ipairs(s.order) do
     if not cleric_in_circle(ally,previous:get_location(),5) then break end
     cleric_heal(c,ally,.25); previous=ally
     c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.5,.7+i*.2)
    end
    s.chainAt=nil; s.restUntil=s.tick+50
   end
   return
  end
  if s.ascendAt then
   if s.lifted:is_alive() and s.tick%4==0 then cleric_tether(c,c.boss,s.lifted,false) end
   if s.tick>=s.ascendAt then
    s.ascendAt=nil; s.liftUntil=s.tick+60; s.restUntil=s.tick+30
    if s.lifted:is_alive() then s.lifted:apply_potion_effect('SPEED',60,0) end
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Seraph Instructor: &fNow the last shall receive first. Follow the light again.')
   local last=s.attendants[#s.attendants]
   if last:is_alive() and radiant_flight(c,last:get_location()) then s.restUntil=s.tick+60; return end
  end
  if s.tick>=s.nextChain and s.healingLeft>0 then
   s.nextChain=s.tick+440; s.order=chain_order(c); s.chainAt=s.tick+40; s.channelDamage=0
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_BEACON_AMBIENT',.6,1.4)
  elseif s.tick>=s.nextAscend then
   s.nextAscend=s.tick+480; s.lifted=nil
   for _,ally in ipairs(s.attendants) do
    if ally:is_alive() and (not s.lifted or ally:get_health()/ally:get_maximum_health()
      <s.lifted:get_health()/s.lifted:get_maximum_health()) then s.lifted=ally end
   end
   if s.lifted then
    s.ascendAt=s.tick+30; c.boss:set_ai_enabled(false)
    c.boss:play_sound_at_self('ENTITY_ALLAY_AMBIENT_WITHOUT_ITEM',.6,1.4)
   end
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if not s.chainAt or c.event.is_damage_transfer then return end
  s.channelDamage=s.channelDamage+c.event.get_damage_amount()
  if s.channelDamage>=c.boss:get_maximum_health()*.025 then
   s.chainAt=nil; s.restUntil=s.tick+50
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.5)
   c.boss:send_message('&6Seraph Instructor: &fThe prayer breaks here. You chose your moment.',24)
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer or not s.lifted or c.event.entity.uuid~=s.lifted.uuid
    or (s.liftUntil or 0)<=(s.tick or 0) or not cleric_in_circle(s.lifted,c.boss:get_location(),6) then return end
  if c.event:transfer_damage(c.boss,c.event.get_damage_amount()*.3) then c.event.multiply_damage_amount(.7) end
 end,
 on_death=function(c)
  c.boss:send_message('&6Seraph Instructor: &fYou understood the bond and the space it needed. Carry that lesson gently.',24)
 end
}
