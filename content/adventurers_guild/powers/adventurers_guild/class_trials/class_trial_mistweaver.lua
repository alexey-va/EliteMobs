-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- Restorative Tide advances through four overlapping pools along a fixed path.
-- It heals each attendant once and strikes the challenger once per cast.
-- Veilstep is a native sidestep with a highlighted destination, never a teleport.
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.attendants={}
  for i=1,2 do
   local ally=c.world:spawn_custom_boss_at_location('class_trial_shaman_attendant.yml',
    {world=p.world,x=p.x+(i==1 and -3 or 3),y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(ally,'Mistweaver attendant could not spawn'); table.insert(c.state.attendants,ally)
  end
  c.state.healingLeft=c.boss:get_maximum_health()*.18
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextTide=60; s.nextVeil=220
   player:send_message('&6Mistweaver Instructor: &fThe tide follows its course. Step aside, and watch who it carries.')
  end
  if s.tideAt then
   if s.tick<s.tideAt then
    if s.tick%5==0 then for _,pool in ipairs(s.pools) do show_circle(c,pool,85,180,225) end end
   elseif s.tick<s.tideAt+48 then
    local index=math.min(4,math.floor((s.tick-s.tideAt)/12)+1); local pool=s.pools[index]
    if s.tick%4==0 then show_circle(c,pool,120,225,245) end
    for _,ally in ipairs(s.attendants) do
     if not s.healed[ally.uuid] and ally:is_alive() and pool:contains(ally:get_location()) then
      s.healed[ally.uuid]=true; cleric_heal(c,ally,.2)
     end
    end
    if not s.tideHit and pool:contains(player:get_location()) then
     s.tideHit=true; c.script:damage(pool:full_target(),1,.65)
    end
   else s.tideAt=nil; s.restUntil=s.tick+50 end
   return
  end
  if s.veilAt then
   if s.tick%4==0 then
    for i,zone in ipairs(s.veilZones) do show_circle(c,zone,i==s.chosen and 245 or 85,220,i==s.chosen and 150 or 245) end
   end
   if s.tick>=s.veilAt then
    c.boss:set_velocity_vector({x=s.stepX,y=.12,z=s.stepZ})
    s.veilAt=nil; s.veilUntil=s.tick+40; s.restUntil=s.tick+50
    c.boss:spawn_particle_at_self({particle='CLOUD',amount=12},1)
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; local weakest=nil
   for _,ally in ipairs(s.attendants) do
    if ally:is_alive() and (not weakest or ally:get_health()/ally:get_maximum_health()<weakest:get_health()/weakest:get_maximum_health()) then weakest=ally end
   end
   player:send_message('&6Mistweaver Instructor: &fThe mist turns. Follow the golden light, not its reflection.')
   if weakest and radiant_flight(c,weakest:get_location()) then s.restUntil=s.tick+60; return end
  end
  local p,q=c.boss:get_location(),player:get_location(); local dx,dz=q.x-p.x,q.z-p.z
  local distance=math.sqrt(dx*dx+dz*dz); if distance<.01 then dx,dz,distance=0,1,1 end
  dx,dz=dx/distance,dz/distance
  if s.tick>=s.nextTide then
   s.nextTide=s.tick+440; s.tideAt=s.tick+36; s.pools={}; s.healed={}; s.tideHit=false
   for i=1,4 do s.pools[i]=ground_circle(c,{world=p.world,x=p.x+dx*i*2,y=p.y,z=p.z+dz*i*2},2.5) end
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_CONDUIT_AMBIENT_SHORT',.6,1)
  elseif s.tick>=s.nextVeil then
   s.nextVeil=s.tick+400; s.veilAt=s.tick+30; s.chosen=s.phaseTwo and 2 or 1; s.veilZones={}
   for i=1,2 do
    local sign=i==1 and 1 or -1
    s.veilZones[i]=ground_circle(c,{world=p.world,x=p.x-dz*3*sign,y=p.y,z=p.z+dx*3*sign},.6)
   end
   local sign=s.chosen==1 and 1 or -1; s.stepX=-dz*.6*sign; s.stepZ=dx*.6*sign
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('ENTITY_ALLAY_AMBIENT_WITHOUT_ITEM',.6,1.4)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if (c.state.veilUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(.75) end
 end,
 on_death=function(c)
  c.boss:send_message('&6Mistweaver Instructor: &fYou kept your footing when the path was hard to see. That will serve you well.',24)
 end
}
