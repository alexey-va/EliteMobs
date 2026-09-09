-- @include ground_markers.inc
-- @include mobility/leap_slam.inc

return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.construct=c.world:spawn_custom_boss_at_location('class_trial_training_construct.yml',
   {world=p.world,x=p.x+4,y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.construct,'Titanbane construct could not spawn')
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextAnchor=50; s.nextKiller=200
   player:send_message('&6Titanbane Instructor: &fA giant is only dangerous while it can reach you. Watch the anchor.')
  end
  if s.stake then
   if not s.stake:is_alive() or not s.construct:is_alive() or s.tick>=s.anchorUntil then
    local broken=not s.stake:is_alive()
    if s.stake:is_alive() then s.stake:remove_elite() end
    s.stake=nil
    if s.construct:is_alive() then s.construct:set_ai_enabled(true) end
    if broken then
     s.killerAt=nil; s.nextKiller=s.tick+400; s.busyUntil=s.tick+60; s.exposedUntil=s.tick+60; pause_movement(c,60)
     player:send_message('&6Titanbane Instructor: &fAnchor broken. You have the opening.')
    end
   elseif s.tick%5==0 then
    local a,b=s.stake:get_location(),s.construct:get_location()
    for i=0,8 do c.world:spawn_particle_at_location({world=a.world,x=a.x+(b.x-a.x)*i/8,
     y=a.y+.8,z=a.z+(b.z-a.z)*i/8},{particle='DUST',red=230,green=200,blue=110,amount=1},1) end
   end
  end
  if s.anchorAt then
   if s.tick%4==0 then show_circle(c,s.anchorZone,230,200,110) end
   if s.tick>=s.anchorAt then
    s.anchorAt=nil
    if s.construct:is_alive() then
     s.stake=c.world:spawn_custom_boss_at_location('class_trial_chain_stake.yml',s.anchorPosition,
      {level=c.boss.level,add_as_reinforcement=true,silent=true})
     assert(s.stake,'Titanbane chain stake could not spawn')
     s.anchorUntil=s.tick+120; s.construct:set_ai_enabled(false); s.nextKiller=s.tick+30
    end
    s.busyUntil=s.tick+30
   end
   return
  end
  if s.killerAt then
   if s.tick%4==0 then show_circle(c,s.killer,190,130,80) end
   if s.tick>=s.killerAt then
    c.script:damage(s.killer:full_target(),1,.9); s.killerAt=nil; s.busyUntil=s.tick+60; s.exposedUntil=s.tick+60
    c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.6,.6)
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Titanbane Instructor: &fControl the reach, and size means very little.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextAnchor and not s.stake and s.construct:is_alive() then
   s.nextAnchor=s.tick+440; local q=s.construct:get_location()
   s.anchorPosition={world=q.world,x=q.x+2,y=q.y,z=q.z}; s.anchorZone=ground_circle(c,s.anchorPosition,.8)
   s.anchorAt=s.tick+40; pause_movement(c,70); c.boss:play_sound_at_self('BLOCK_CHAIN_PLACE',.6,.7)
  elseif s.tick>=s.nextKiller then
   s.nextKiller=s.tick+400
   local aim=s.stake and s.construct:get_location() or player:get_location()
   s.killer=forward_cone(c,c.boss:get_location(),aim,10,.7); s.killerAt=s.tick+40; pause_movement(c,100)
   c.boss:face_direction_or_location(aim); c.boss:play_sound_at_self('BLOCK_CHAIN_PLACE',.6,.9)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.25) end
 end,
 on_death=function(c) c.boss:send_message('&6Titanbane Instructor: &fYou chose what to break. That matters more than how hard you swing.',24) end
}
