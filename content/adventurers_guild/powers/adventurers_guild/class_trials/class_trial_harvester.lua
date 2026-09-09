-- @include ground_markers.inc
-- @include mobility/leap_slam.inc

local function new_effigies(c)
 local s=c.state; local p=c.boss:get_location(); s.effigies={}; s.pairs=(s.pairs or 0)+1
 for i=1,2 do
  local actor=c.world:spawn_custom_boss_at_location('class_trial_wounded_effigy.yml',
   {world=p.world,x=p.x+(i==1 and -3 or 3),y=p.y,z=p.z+3},
   {level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(actor,'Harvester effigy could not spawn'); s.effigies[i]=actor
 end
end
local function break_chain(c)
 local s=c.state; s.chainAt=nil; s.movingUntil=nil; s.leg=nil; s.busyUntil=s.tick+60; s.exposedUntil=s.tick+60
 pause_movement(c,60)
 c.boss:send_message('&6Harvester Instructor: &fA missing link. My reach ends there.',24)
end
return {
 api_version=1,
 on_spawn=function(c) new_effigies(c) end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextReap=40; s.nextChain=140
   player:send_message('&6Harvester Instructor: &fThose wounded effigies feed the chain. Take them from me.')
  end
  if s.reapAt then
   if s.tick%4==0 then show_circle(c,s.reap,185,55,55) end
   if s.tick>=s.reapAt then
    local q=player:get_location(); q.y=q.y+.75
    if s.reap:contains(q) then player:push_relative_to(c.boss:get_location(),-.22,0,.04,0) end
    s.reapAt=nil; s.busyUntil=s.tick+30
   end
   return
  end
  if s.chainAt then
   local actor=s.effigies[s.leg]
   if actor and not actor:is_alive() then break_chain(c); return end
   if s.tick%4==0 then show_circle(c,s.chain,185,55,55) end
   if s.tick>=s.chainAt then
    s.chainAt=nil; s.movingUntil=s.tick+32
    c.boss:set_ai_enabled(true); c.boss:navigate_to_location(s.destination,.85,false,32)
   end
   return
  end
  if s.movingUntil then
   local actor=s.effigies[s.leg]
   if actor and not actor:is_alive() then break_chain(c); return end
   if s.tick>=s.movingUntil then
    local q=c.boss:get_location(); local d=s.destination
    if (q.x-d.x)^2+(q.z-d.z)^2>2.25 then break_chain(c); return end
    if actor then
     actor:remove_elite(); c.boss:restore_health(c.boss:get_maximum_health()*.02)
     c.boss:spawn_particle_at_self({particle='DUST',red=185,green=45,blue=45,amount=4},1)
    else c.script:damage(s.chain:full_target(),1,.85) end
    s.movingUntil=nil; s.leg=s.leg+1
    if s.leg>3 then s.leg=nil; s.busyUntil=s.tick+60; s.exposedUntil=s.tick+60; pause_movement(c,60)
    else
     local nextActor=s.effigies[s.leg]
     if nextActor and not nextActor:is_alive() then break_chain(c); return end
     s.destination=nextActor and nextActor:get_location() or player:get_location()
     s.chain=forward_cone(c,c.boss:get_location(),s.destination,8,.8); s.chainAt=s.tick+24; pause_movement(c,24)
    end
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Harvester Instructor: &fYou can break the chain before it ever reaches you.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  local alive=false; for _,actor in ipairs(s.effigies) do if actor:is_alive() then alive=true end end
  if not alive and s.pairs<3 and s.tick>=s.nextChain then
   new_effigies(c); s.busyUntil=s.tick+50
  elseif s.tick>=s.nextChain and alive then
   s.nextChain=s.tick+460; s.leg=1
   if not s.effigies[1]:is_alive() then break_chain(c); return end
   s.destination=s.effigies[1]:get_location(); s.chain=forward_cone(c,c.boss:get_location(),s.destination,8,.8)
   s.chainAt=s.tick+36; pause_movement(c,36); c.boss:play_sound_at_self('BLOCK_CHAIN_PLACE',.6,.8)
  elseif s.tick>=s.nextReap then
   s.nextReap=s.tick+360; s.reap=forward_cone(c,c.boss:get_location(),player:get_location(),6,.8)
   s.reapAt=s.tick+32; pause_movement(c,62); c.boss:play_sound_at_self('BLOCK_CHAIN_PLACE',.5,.6)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Harvester Instructor: &fThe chain has nothing left to hold. You saw to that.',24) end
}
