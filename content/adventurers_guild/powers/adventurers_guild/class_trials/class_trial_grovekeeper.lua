-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- Two destructible roots sustain a fixed garden. Thorn Ward marks four small
-- patches with walkable gaps, protects attendants inside the garden, and ends
-- immediately when the last root falls. It never cages the challenger in blocks.
local function end_garden(c,broken)
 local s=c.state
 for _,root in ipairs(s.roots or {}) do if root:is_alive() then root:remove_elite() end end
 if s.wardAt then s.restUntil=s.tick+30 end
 s.roots=nil; s.gardenUntil=0; s.wardUntil=0; s.wardAt=nil
 if broken then
  s.exposedUntil=s.tick+60
  c.boss:send_message('&6Grovekeeper Instructor: &fThe roots are gone. You have opened the garden.',24)
  c.boss:play_sound_at_self('BLOCK_AZALEA_LEAVES_BREAK',.6,.8)
 end
end
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.attendants={}
  for i=1,2 do
   local ally=c.world:spawn_custom_boss_at_location('class_trial_shaman_attendant.yml',
    {world=p.world,x=p.x+(i==1 and -3 or 3),y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(ally,'Grovekeeper attendant could not spawn'); table.insert(c.state.attendants,ally)
  end
  c.state.healingLeft=c.boss:get_maximum_health()*.18
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextBloom=60; s.nextWard=0
   player:send_message('&6Grovekeeper Instructor: &fTwo roots feed this garden. There is room to walk between its thorns.')
  end
  if s.roots then
   local alive=false; for _,root in ipairs(s.roots) do if root:is_alive() then alive=true end end
   if not alive then end_garden(c,true)
   elseif s.tick>=s.gardenUntil then end_garden(c,false)
   else
    if s.tick%5==0 then show_circle(c,s.garden,100,220,120) end
    if s.tick%40==0 then
     for _,ally in ipairs(s.attendants) do if cleric_in_circle(ally,s.anchor,4) then cleric_heal(c,ally,.1) end end
    end
   end
  end
  if (s.wardUntil or 0)>s.tick then
   for _,patch in ipairs(s.thorns) do
    if s.tick%5==0 then show_circle(c,patch,210,150,70) end
    if s.thornHits<2 and s.tick>=s.nextThorn and patch:contains(player:get_location()) then
     s.thornHits=s.thornHits+1; s.nextThorn=s.tick+30
     c.script:damage(patch:full_target(),1,.35)
    end
   end
  end
  if s.bloomAt then
   if s.tick%4==0 then show_circle(c,s.garden,100,220,120) end
   if s.tick>=s.bloomAt then
    s.bloomAt=nil; s.roots={}
    for i=1,2 do
     local root=c.world:spawn_custom_boss_at_location('class_trial_garden_root.yml',
      {world=s.anchor.world,x=s.anchor.x+(i==1 and -3 or 3),y=s.anchor.y,z=s.anchor.z},
      {level=c.boss.level,add_as_reinforcement=true,silent=true})
     assert(root,'Garden Root could not spawn'); table.insert(s.roots,root)
    end
    s.gardenUntil=s.tick+160; s.restUntil=s.tick+30
   end
   return
  end
  if s.wardAt then
   if s.tick%4==0 then for _,patch in ipairs(s.thorns) do show_circle(c,patch,245,195,110) end end
   if s.tick>=s.wardAt then
    s.wardAt=nil; s.wardUntil=math.min(s.tick+80,s.gardenUntil)
    s.thornHits=0; s.nextThorn=s.tick; s.restUntil=s.tick+30
    c.boss:play_sound_at_self('BLOCK_SWEET_BERRY_BUSH_PLACE',.6,.8)
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.phaseTwo and not s.roots and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Grovekeeper Instructor: &fA new clearing, then. The roots must take hold again.')
   local ally=s.attendants[1]
   if ally:is_alive() and radiant_flight(c,ally:get_location()) then s.restUntil=s.tick+60; return end
  end
  if not s.roots and s.tick>=s.nextBloom then
   s.nextBloom=s.tick+480; s.anchor=c.boss:get_location(); s.garden=ground_circle(c,s.anchor,4)
   s.bloomAt=s.tick+36; c.boss:set_ai_enabled(false)
   c.boss:play_sound_at_self('BLOCK_AZALEA_LEAVES_PLACE',.6,.8)
  elseif s.roots and s.tick>=s.nextWard and s.gardenUntil>s.tick+32 then
   s.nextWard=s.tick+440; s.wardAt=s.tick+32; s.thorns={}
   for i=1,4 do
    local angle=i*math.pi/2
    s.thorns[i]=ground_circle(c,{world=s.anchor.world,x=s.anchor.x+math.cos(angle)*3.5,y=s.anchor.y,z=s.anchor.z+math.sin(angle)*3.5},.85)
   end
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_GRASS_PLACE',.6,.8)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if (s.wardUntil or 0)<=(s.tick or 0) then return end
  for _,ally in ipairs(s.attendants or {}) do
   if c.event.entity.uuid==ally.uuid and cleric_in_circle(ally,s.anchor,4) then c.event.multiply_damage_amount(.75); return end
  end
 end,
 on_death=function(c)
  c.boss:send_message('&6Grovekeeper Instructor: &fYou found the roots beneath the flowers. Tend your own with care.',24)
 end
}
