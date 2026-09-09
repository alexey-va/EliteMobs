-- @include ground_markers.inc
-- @include mobility/windstep.inc
-- @include abilities/arrow_lanes.inc

return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.targets={}
  for i=1,3 do
   local actor=c.world:spawn_custom_boss_at_location('class_trial_paper_target.yml',
    {world=p.world,x=p.x+(i-2)*3,y=p.y,z=p.z+4},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(actor,'Bowmaster paper target could not spawn'); c.state.targets[i]=actor
  end
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextSight=40; s.nextFlight=110
   player:send_message('&6Bowmaster Instructor: &fEach target gives me another line. Clear the field if you need room.')
  end
  if (s.sightUntil or 0)>s.tick and s.tick%10==0 then player:spawn_particle_at_self({particle='END_ROD',amount=1},1) end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then arrow_lanes(c,s.aim,s.angles,1.1,false) end
   if s.tick>=s.fireAt then
    local angles={0}; for i,actor in ipairs(s.targets) do if actor:is_alive() then angles[#angles+1]=({-18,7,18})[i] end end
    arrow_lanes(c,s.aim,angles,1.1,true); s.fireAt=nil; s.busyUntil=s.tick+110
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Bowmaster Instructor: &fThe targets stay broken. You earned that space.'); return
  end
  if s.tick>=s.nextSight then
   s.nextSight=s.tick+400; s.busyUntil=s.tick+46; c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_FLUTE',.6,1.4)
   c.scheduler:run_later(26,function() s.sightUntil=s.tick+140 end)
  elseif s.tick>=s.nextFlight then
   s.nextFlight=s.tick+280; s.aim=player:get_eye_location(); s.fireAt=s.tick+38; s.lockAt=s.tick+22; s.angles={0}
   for i,actor in ipairs(s.targets) do if actor:is_alive() then s.angles[#s.angles+1]=({-18,7,18})[i] end end
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_HARP',.6,.7)
  end
 end,
 on_player_damaged_by_boss=function(c)
  if c.event.projectile then c.event.multiply_damage_amount((c.state.sightUntil or 0)>(c.state.tick or 0) and .4 or .35) end
 end,
 on_death=function(c) c.boss:send_message('&6Bowmaster Instructor: &fYou saw the whole field. Keep looking past the first arrow.',24) end
}
