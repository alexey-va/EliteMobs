-- @include ground_markers.inc
-- @include mobility/windstep.inc
-- @include abilities/arrow_lanes.inc

return {
 api_version=1,
 on_spawn=function(c) c.state.anchors={}; c.state.triggerReady=0 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextWires=40; s.nextZone=220
   player:send_message('&6Trapper Instructor: &fLook between the traps. There is always a path.')
  end
  for _,wire in ipairs(s.anchors) do
   if wire.actor:is_alive() then
    if s.tick>=s.wiresUntil then wire.actor:remove_elite()
    else
     local inside=wire.zone:contains(player:get_location())
     if s.tick%5==0 then show_circle(c,wire.zone,190,165,90) end
     if inside and not wire.inside and s.tick>=s.triggerReady and s.tick>=(s.pauseWiresUntil or 0) then
      player:apply_potion_effect('SLOWNESS',20,0); s.triggerReady=s.tick+60
      c.boss:play_sound_at_self('BLOCK_TRIPWIRE_CLICK_ON',.5,.9)
     end
     wire.inside=inside
    end
   end
  end
  if s.plantAt then
   if s.tick%4==0 then for _,point in ipairs(s.wirePoints) do show_circle(c,ground_circle(c,point,1.5),190,165,90) end end
   if s.tick>=s.plantAt then
    s.plantAt=nil; s.anchors={}; s.wiresUntil=s.tick+160; s.busyUntil=s.tick+30
    for _,point in ipairs(s.wirePoints) do
     local actor=c.world:spawn_custom_boss_at_location('class_trial_snare_beacon.yml',point,
      {level=c.boss.level,add_as_reinforcement=true,silent=true})
     assert(actor,'Trapper anchor could not spawn'); s.anchors[#s.anchors+1]={actor=actor,zone=ground_circle(c,point,1.5)}
    end
   end
   return
  end
  if s.cellAt then
   if s.tick%4==0 then for _,cell in ipairs(s.cells) do show_circle(c,cell,220,160,80) end end
   if s.tick>=s.cellAt then
    if not s.caught and s.cells[s.cell]:contains(player:get_location()) then player:apply_potion_effect('SLOWNESS',10,1); s.caught=true end
    s.cell=s.cell+1
    if s.cell>3 then
     s.cellAt=nil; s.busyUntil=s.tick+40
     c.scheduler:run_later(40,function()
      if not player:is_alive() then return end
      s.fireAt=s.tick+38; s.lockAt=s.tick+22; s.aim=player:get_eye_location()
      c.boss:play_sound_at_self('ITEM_CROSSBOW_LOADING_START',.5,.7)
     end)
    else s.cellAt=s.tick+26 end
   end
   return
  end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then arrow_lanes(c,s.aim,{0},.95,false) end
   if s.tick>=s.fireAt then arrow_lanes(c,s.aim,{0},.95,true); s.fireAt=nil; s.busyUntil=s.tick+120 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Trapper Instructor: &fYou found the path. Now keep it in sight.'); return
  end
  if s.tick>=s.nextWires then
   s.nextWires=s.tick+480; local q=player:get_location(); s.wirePoints={}
   for _,side in ipairs({-2.5,2.5}) do s.wirePoints[#s.wirePoints+1]={world=q.world,x=q.x+side,y=q.y,z=q.z} end
   s.plantAt=s.tick+36; c.boss:play_sound_at_self('BLOCK_TRIPWIRE_ATTACH',.5,.7)
  elseif s.tick>=s.nextZone then
   s.nextZone=s.tick+440; local q=player:get_location(); s.cells={}; s.cell=1; s.caught=false
   for _,offset in ipairs({{-1.5,-1.5},{1.5,-1.5},{0,1.5}}) do
    s.cells[#s.cells+1]=ground_circle(c,{world=q.world,x=q.x+offset[1],y=q.y,z=q.z+offset[2]},.8)
   end
   s.cellAt=s.tick+38; s.pauseWiresUntil=s.tick+250; c.boss:play_sound_at_self('BLOCK_TRIPWIRE_ATTACH',.5,1.2)
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.6) end end,
 on_death=function(c) c.boss:send_message('&6Trapper Instructor: &fYou looked for the path before you looked for me. Good instincts.',24) end
}
