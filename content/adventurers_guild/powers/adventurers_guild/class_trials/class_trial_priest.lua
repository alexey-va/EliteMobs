-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- Prayer visibly visits the weakest living attendants first. Damage during its
-- channel interrupts the entire sequence; Purify protects only one attendant.
local function wounded(c)
 local result={}
 for _,ally in ipairs(c.state.attendants) do
  if ally:is_alive() and ally:get_health()<ally:get_maximum_health() then table.insert(result,ally) end
 end
 table.sort(result,function(a,b) return a:get_health()/a:get_maximum_health()<b:get_health()/b:get_maximum_health() end)
 return result
end
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.attendants={}
  for i=1,3 do
   local ally=c.world:spawn_custom_boss_at_location('class_trial_priest_attendant.yml',
    {world=p.world,x=p.x+(i-2)*2,y=p.y,z=p.z+3},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(ally,'Priest attendant could not spawn')
   table.insert(c.state.attendants,ally)
  end
  c.state.healingLeft=c.boss:get_maximum_health()*.18
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextPrayer=80; s.nextPurify=200
   player:send_message('&6Priest Instructor: &fFollow the prayer. The weakest receive it first.')
  end
  if s.protected and s.protected:is_alive() and s.tick<(s.protectUntil or 0) and s.tick%5==0 then
   s.protected:spawn_particle_at_self({particle='END_ROD',amount=2},1)
  end
  if s.prayerAt then
   local recipient=s.chosen[s.pulse or 1]
   if recipient and recipient:is_alive() and s.tick%4==0 then cleric_tether(c,c.boss,recipient,false) end
   if s.tick>=s.prayerAt then
    cleric_heal(c,recipient,recipient and recipient.uuid==c.boss.uuid and .015 or .25)
    c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.6,.8+(s.pulse or 1)*.2)
    s.pulse=(s.pulse or 1)+1
    if s.pulse>#s.chosen then s.prayerAt=nil; s.restUntil=s.tick+50
    else s.prayerAt=s.tick+8 end
   end
   return
  end
  if s.purifyAt then
   if s.protected:is_alive() and s.tick%4==0 then cleric_tether(c,c.boss,s.protected,false) end
   if s.tick>=s.purifyAt then
    s.purifyAt=nil; s.protectUntil=s.tick+60; s.restUntil=s.tick+30
    cleric_heal(c,s.protected,.08)
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  local injured=wounded(c)
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Priest Instructor: &fThere is still time to reach someone. Watch where I land.')
   if injured[1] and radiant_flight(c,injured[1]:get_location()) then s.restUntil=s.tick+60; return end
  end
  if s.tick>=s.nextPrayer and s.healingLeft>0 then
   s.nextPrayer=s.tick+400; s.chosen=injured
   if #s.chosen==0 then s.chosen={c.boss} end
   s.pulse=1; s.prayerAt=s.tick+40; s.channelDamage=0
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_BEACON_AMBIENT',.6,1.3)
  elseif s.tick>=s.nextPurify and injured[1] then
   s.nextPurify=s.tick+360; s.protected=injured[1]; s.purifyAt=s.tick+28
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,1.5)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if not s.prayerAt or c.event.is_damage_transfer then return end
  s.channelDamage=s.channelDamage+c.event.get_damage_amount()
  if s.channelDamage>=c.boss:get_maximum_health()*.025 then
   s.prayerAt=nil; s.restUntil=s.tick+50
   c.boss:set_ai_enabled(false)
   c.boss:send_message('&6Priest Instructor: &fA clear answer. I must find another moment.',24)
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.5)
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if not c.event.is_damage_transfer and s.protected and c.event.entity.uuid==s.protected.uuid
    and (s.protectUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(.6) end
 end,
 on_death=function(c)
  c.boss:send_message('&6Priest Instructor: &fYou kept sight of those in need. Carry that care with you.',24)
 end
}
