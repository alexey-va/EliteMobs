-- @include ground_markers.inc
-- @include mobility/windstep.inc
-- @include abilities/arrow_lanes.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextCache=40; s.nextBurst=170
   player:send_message('&6Artillerist Instructor: &fFour bolts. That cache keeps them coming. You may wish to do something about it.')
  end
  if s.cache and (not s.cache:is_alive() or s.tick>=s.cacheUntil) then
   if s.cache:is_alive() then s.cache:remove_elite() end
   s.cache=nil; s.quickLoaded=false
   if s.reloadAt then
    s.reloadAt=nil; s.busyUntil=s.tick+50; s.exposedUntil=s.tick+50
    player:send_message('&6Artillerist Instructor: &fSupply cut. You bought yourself time.')
   end
  end
  if s.plantAt then
   if s.tick%4==0 then show_circle(c,s.cacheZone,240,210,130) end
   if s.tick>=s.plantAt then
    s.plantAt=nil; s.cache=c.world:spawn_custom_boss_at_location('class_trial_ammunition_cache.yml',s.cachePosition,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.cache,'Artillerist cache could not spawn')
    s.cacheUntil=s.tick+200; s.reloadAt=s.tick+40; s.pressure=0
   end
   return
  end
  if s.reloadAt then
   if s.tick%8==0 then show_circle(c,s.cacheZone,240,210,130); c.boss:play_sound_at_self('ITEM_CROSSBOW_LOADING_MIDDLE',.5,1) end
   if s.tick>=s.reloadAt then s.reloadAt=nil; s.quickLoaded=true; s.busyUntil=s.tick+30 end
   return
  end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then arrow_lanes(c,s.aim,{0},1.1,false) end
   if s.tick>=s.fireAt then
    arrow_lanes(c,s.aim,{0},1.1,true); s.bolt=s.bolt+1
    if s.bolt>4 then s.fireAt=nil; s.busyUntil=s.tick+110; s.exposedUntil=s.tick+110
    else s.aim=player:get_eye_location(); s.fireAt=s.tick+s.cadence; s.lockAt=s.tick+s.cadence-7 end
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Artillerist Instructor: &fCount them. The fourth is still part of the lesson.'); return
  end
  if s.tick>=s.nextCache and not s.cache then
   s.nextCache=s.tick+520; local q=c.boss:get_location()
   s.cachePosition={world=q.world,x=q.x+2,y=q.y,z=q.z}; s.cacheZone=ground_circle(c,s.cachePosition,.8)
   s.plantAt=s.tick+36; c.boss:play_sound_at_self('BLOCK_BARREL_OPEN',.5,.8)
  elseif s.tick>=s.nextBurst then
   s.nextBurst=s.tick+320; s.bolt=1; s.cadence=s.quickLoaded and 13 or 18; s.quickLoaded=false
   s.aim=player:get_eye_location(); s.fireAt=s.tick+34; s.lockAt=s.tick+24
   c.boss:play_sound_at_self('ITEM_CROSSBOW_LOADING_START',.6,.7)
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.25) end end,
 on_boss_damaged_by_player=function(c)
  if c.event.is_damage_transfer then return end
  local s=c.state
  if s.reloadAt then
   s.pressure=s.pressure+c.event.get_damage_amount()
   if s.pressure>=c.boss:get_maximum_health()*.035 then
    s.reloadAt=nil; s.quickLoaded=false; s.busyUntil=s.tick+50; s.exposedUntil=s.tick+50
    c.boss:send_message('&6Artillerist Instructor: &fThe mechanism can wait. You did not.',24)
   end
  end
  if (s.exposedUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Artillerist Instructor: &fYou counted the bolts and broke the supply. Nicely done.',24) end
}
