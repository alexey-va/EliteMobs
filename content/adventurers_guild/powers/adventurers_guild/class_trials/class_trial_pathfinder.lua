-- @include ground_markers.inc
-- @include mobility/windstep.inc
-- @include abilities/arrow_lanes.inc

return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.wolf=c.world:spawn_custom_boss_at_location('class_trial_training_wolf.yml',
   {world=p.world,x=p.x+3,y=p.y,z=p.z+1},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.wolf,'Pathfinder wolf could not spawn')
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextTrail=40; s.nextPack=160
   player:send_message('&6Pathfinder Instructor: &fThe beacon guides the pack. Break it, or make us leave its light.')
  end
  if s.beacon then
   if not s.beacon:is_alive() or s.tick>=s.trailUntil then
    if s.beacon:is_alive() then s.beacon:remove_elite() end
    s.beacon=nil
   elseif s.tick%5==0 then
    show_circle(c,s.trail,145,225,180)
    if s.wolf:is_alive() and s.trail:contains(s.wolf:get_location()) then s.wolf:apply_potion_effect('SPEED',10,0) end
   end
  end
  if s.plantAt then
   if s.tick%4==0 then show_circle(c,s.trail,145,225,180) end
   if s.tick>=s.plantAt then
    s.plantAt=nil; s.beacon=c.world:spawn_custom_boss_at_location('class_trial_trail_beacon.yml',s.trailPosition,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.beacon,'Pathfinder trail beacon could not spawn'); s.trailUntil=s.tick+160; s.busyUntil=s.tick+30
   end
   return
  end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then arrow_lanes(c,s.aim,{0},.95,false) end
   if s.tick>=s.fireAt then arrow_lanes(c,s.aim,{0},.95,true); s.fireAt=nil; s.busyUntil=s.tick+116 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Pathfinder Instructor: &fKeep an eye on my companion. The bow is only half the lesson.'); return
  end
  if s.tick>=s.nextTrail and not s.beacon then
   s.nextTrail=s.tick+480; local q=player:get_location(); local a=c.boss:get_location()
   s.trailPosition={world=a.world,x=(a.x+q.x)/2,y=a.y,z=(a.z+q.z)/2}; s.trail=ground_circle(c,s.trailPosition,4)
   s.plantAt=s.tick+34; c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_FLUTE',.6,1.4)
  elseif s.tick>=s.nextPack then
   s.nextPack=s.tick+360; s.fireAt=s.tick+54; s.lockAt=s.tick+40; s.aim=player:get_eye_location()
   c.boss:play_sound_at_self('ENTITY_WOLF_GROWL',.6,1)
   if s.wolf:is_alive() then
    local a,b=s.wolf:get_location(),player:get_location(); local dx,dz=b.x-a.x,b.z-a.z; local d=math.sqrt(dx*dx+dz*dz)
    if d>2 and d<8 then
     local landing=ground_circle(c,b,1.2); show_circle(c,landing,145,225,180)
     c.scheduler:run_later(20,function()
      if s.wolf:is_alive() then s.wolf:set_velocity_vector({x=dx/d*.35,y=.35,z=dz/d*.35}) end
     end)
    end
   end
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.55) end end,
 on_death=function(c) c.boss:send_message('&6Pathfinder Instructor: &fYou watched the pack and chose your ground. You will find your way.',24) end
}
