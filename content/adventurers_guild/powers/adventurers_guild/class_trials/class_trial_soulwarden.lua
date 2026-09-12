-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- Communion divides part of an ordinary damage event among nearby partners.
-- A full second of separation severs a thread. Intervention is spent even when
-- its forty-tick prayer is interrupted, so each attendant has only one rescue.
local function share(c,victim)
 local s=c.state
 if c.event.is_damage_transfer or (s.communionUntil or 0)<=(s.tick or 0) then return end
 local eligible=victim.uuid==c.boss.uuid; local recipients={}
 if victim.uuid~=c.boss.uuid then recipients[#recipients+1]=c.boss end
 for i,ally in ipairs(s.attendants) do
  if s.links[i] and cleric_in_circle(ally,c.boss:get_location(),6) then
   if victim.uuid==ally.uuid then eligible=true else recipients[#recipients+1]=ally end
  end
 end
 if not eligible or #recipients==0 then return end
 local amount=c.event.get_damage_amount(); if amount<=0 then return end
 local portion=amount*.4/#recipients; local sent=0
 for _,recipient in ipairs(recipients) do
  if c.event:transfer_damage(recipient,portion) then sent=sent+portion end
 end
 c.event.multiply_damage_amount((amount-sent)/amount)
end
local function absorb(c)
 local s=c.state; local id=c.event.entity.uuid; local shield=s.shields and s.shields[id]
 if not shield or shield.untilTick<=(s.tick or 0) then return end
 local amount=c.event.get_damage_amount(); if amount<=0 then return end
 local used=math.min(amount,shield.amount); shield.amount=shield.amount-used
 c.event.multiply_damage_amount((amount-used)/amount)
end
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); local s=c.state
  s.attendants={}; s.links={}; s.interventions={}; s.shields={}
  for i=1,2 do
   local ally=c.world:spawn_custom_boss_at_location('class_trial_priest_attendant.yml',
    {world=p.world,x=p.x+(i==1 and -3 or 3),y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(ally,'Soulwarden attendant could not spawn'); table.insert(s.attendants,ally)
  end
  s.healingLeft=c.boss:get_maximum_health()*.18
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextCommunion=60
   player:send_message('&6Soulwarden Instructor: &fNo one bears the whole wound while these threads remain.')
  end
  if (s.communionUntil or 0)>s.tick then
   local count=0
   for i,ally in ipairs(s.attendants) do
    local link=s.links[i]
    if link then
     local close=cleric_in_circle(ally,c.boss:get_location(),6)
     link.separated=close and 0 or link.separated+1
     if not ally:is_alive() or link.separated>=20 then
      s.links[i]=nil; c.boss:play_sound_at_self('BLOCK_CHAIN_BREAK',.5,1.2)
     else
      count=count+1
      if s.tick%5==0 then cleric_tether(c,c.boss,ally,not close) end
     end
    end
   end
   if count==0 and s.hadLinks then
    s.hadLinks=false; s.communionUntil=0; s.exposedUntil=s.tick+60
    player:send_message('&6Soulwarden Instructor: &fThe burden is mine alone now. You saw the threads.')
   end
  end
  for _,ally in ipairs(s.attendants) do
   local shield=s.shields[ally.uuid]
   if shield and shield.untilTick>s.tick and shield.amount>0 and ally:is_alive() and s.tick%6==0 then
    ally:spawn_particle_at_self({particle='END_ROD',amount=3},1)
   end
  end
  if s.castAt then
   if s.tick%4==0 then
    for _,ally in ipairs(s.attendants) do if ally:is_alive() then cleric_tether(c,c.boss,ally,false) end end
   end
   if s.tick>=s.castAt then
    if s.rescuing then
     if s.rescuing:is_alive() then
      cleric_heal(c,s.rescuing,.3)
      s.shields[s.rescuing.uuid]={amount=s.rescuing:get_maximum_health()*.25,untilTick=s.tick+100}
     end
     s.rescuing=nil; s.restUntil=s.tick+60
    else
     s.links={}; s.hadLinks=false; s.communionUntil=s.tick+120
     for i,ally in ipairs(s.attendants) do
      if cleric_in_circle(ally,c.boss:get_location(),6) then s.links[i]={separated=0}; s.hadLinks=true end
     end
     s.restUntil=s.tick+30
    end
    s.castAt=nil
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  local weakest=nil
  for _,ally in ipairs(s.attendants) do
   if ally:is_alive() and (not weakest or ally:get_health()/ally:get_maximum_health()<weakest:get_health()/weakest:get_maximum_health()) then weakest=ally end
  end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Soulwarden Instructor: &fThe frailest thread deserves our attention.')
   if weakest and radiant_flight(c,weakest:get_location()) then s.restUntil=s.tick+60; return end
  end
  for _,ally in ipairs(s.attendants) do
   if ally:is_alive() and not s.interventions[ally.uuid] and ally:get_health()<ally:get_maximum_health()*.3 then
    s.interventions[ally.uuid]=true; s.rescuing=ally; s.castAt=s.tick+40; s.channelDamage=0
    c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_BEACON_AMBIENT',.6,1.4); return
   end
  end
  if weakest and s.tick>=s.nextCommunion then
   s.nextCommunion=s.tick+480; s.castAt=s.tick+36; c.boss:set_ai_enabled(false)
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.6,.8)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer then return end
  if (s.exposedUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.2) end
  if s.castAt and s.rescuing then
   s.channelDamage=s.channelDamage+c.event.get_damage_amount()
   if s.channelDamage>=c.boss:get_maximum_health()*.025 then
    s.castAt=nil; s.rescuing=nil; s.restUntil=s.tick+60
    c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.5)
    c.boss:send_message('&6Soulwarden Instructor: &fThat rescue is spent. You chose your moment.',24)
   end
  end
  share(c,c.boss)
 end,
 on_reinforcement_damaged_by_player=function(c)
  absorb(c)
  share(c,c.event.entity)
 end,
 on_death=function(c)
  c.boss:send_message('&6Soulwarden Instructor: &fYou have learned how a burden is shared. Be worthy of that trust.',24)
 end
}
