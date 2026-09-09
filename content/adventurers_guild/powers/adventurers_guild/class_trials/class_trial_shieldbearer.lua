-- @include ground_markers.inc
-- @include mobility/steed_charge.inc

local function distance(a,b) return math.sqrt((a.x-b.x)^2+(a.z-b.z)^2) end
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.cadets={}; c.state.links={}
  for _,side in ipairs({-1,1}) do
   local cadet=c.world:spawn_custom_boss_at_location('class_trial_guardian_apprentice.yml',
    {x=p.x+side*3,y=p.y,z=p.z+2,world=p.world},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(cadet,'Shieldbearer cadet could not spawn'); table.insert(c.state.cadets,cadet)
  end
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextLinks=65; s.nextCover=230; s.links={}
   player:send_message('&6Shieldbearer Instructor: &fTwo allies. Two promises. Pull them beyond my reach.')
  end
  if s.tick%5==0 then
   for _,cadet in ipairs(s.cadets) do
    local expiry=s.links[cadet.uuid] or 0
    if expiry>s.tick and cadet:is_alive() then
     local a,b=c.boss:get_location(),cadet:get_location()
     if distance(a,b)>7 then
      s.links[cadet.uuid]=0; s.broken=(s.broken or 0)+1
      c.boss:play_sound_at_self('BLOCK_CHAIN_BREAK',.5,1.2)
      if s.broken>=2 then
       s.exposedUntil=s.tick+60
       player:send_message('&6Shieldbearer Instructor: &fBoth promises stretched too far. Well read.')
      end
     else
      for i=0,10 do c.world:spawn_particle_at_location({x=a.x+(b.x-a.x)*i/10,y=a.y+1,z=a.z+(b.z-a.z)*i/10,world=a.world},
       {particle='DUST',red=235,green=220,blue=145,amount=1},1) end
     end
    end
   end
   if (s.coverUntil or 0)>s.tick then show_circle(c,s.cover,220,225,235) end
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.busyUntil=s.tick+65; steed_charge(c,player)
   player:send_message('&6Shieldbearer Instructor: &fKeep watching the formation. The shield moves with it.')
  elseif s.tick>=s.nextLinks then
   s.nextLinks=s.tick+400; s.busyUntil=s.tick+30; s.broken=0
   c.boss:play_sound_at_self('ITEM_SHIELD_BLOCK',.5,1.1)
   c.scheduler:run_later(30,function()
    for _,cadet in ipairs(s.cadets) do if cadet:is_alive() then s.links[cadet.uuid]=s.tick+120 end end
   end)
  elseif s.tick>=s.nextCover then
   s.nextCover=s.tick+480; s.busyUntil=s.tick+30
   s.cover=forward_cone(c,c.boss:get_location(),player:get_location(),7,4)
   c.boss:face_direction_or_location(player:get_location()); pause_movement(c,110)
   c.scheduler:run_later(30,function() s.coverUntil=s.tick+80 end)
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  if c.event.is_damage_transfer then return end
  local s=c.state; local cadet=c.event.entity
  if (s.coverUntil or 0)>(s.tick or 0) then
   local p=cadet:get_location(); p.y=p.y+.75
   if s.cover:contains(p) then c.event.multiply_damage_amount(.65) end
  end
  if (s.links[cadet.uuid] or 0)>(s.tick or 0) and distance(c.boss:get_location(),cadet:get_location())<=7 then
   if c.event:transfer_damage(c.boss,c.event.get_damage_amount()*.5) then c.event.multiply_damage_amount(.5) end
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Shieldbearer Instructor: &fYou saw the people behind the shield. That is where the work begins.',24) end
}
