-- @include ground_markers.inc
-- @include mobility/windstep.inc
-- @include abilities/arrow_lanes.inc
-- @include abilities/powder_charge.inc

-- The bolt plants its payload only on a real player hit. Dodging it denies the
-- charge entirely; after attachment the charge has its own warning and hitbox.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextBeacon=40; s.nextPayload=160; s.triggerReady=0
   player:send_message('&6Saboteur Instructor: &fAvoid the bolt, or break what it leaves behind. You get two warnings.')
  end
  if s.beacon then
   if not s.beacon:is_alive() or s.tick>=s.snareUntil then
    if s.beacon:is_alive() then s.beacon:remove_elite() end
    s.beacon=nil
   else
    if s.tick%5==0 then show_circle(c,s.snare,190,165,90) end
    local inside=s.snare:contains(player:get_location())
    if inside and not s.wasInside and s.tick>=s.triggerReady and s.tick>=(s.snaresPausedUntil or 0) then
     player:apply_potion_effect('SLOWNESS',20,0); s.triggerReady=s.tick+60
     c.boss:play_sound_at_self('BLOCK_TRIPWIRE_CLICK_ON',.5,1)
    end
    s.wasInside=inside
   end
  end
  if s.plantAt then
   if s.tick%4==0 then show_circle(c,s.snare,190,165,90) end
   if s.tick>=s.plantAt then
    s.plantAt=nil; s.beacon=c.world:spawn_custom_boss_at_location('class_trial_snare_beacon.yml',s.snarePosition,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.beacon,'Saboteur snare beacon could not spawn'); s.snareUntil=s.tick+140; s.busyUntil=s.tick+30
   end
   return
  end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then arrow_lanes(c,s.aim,{0},.95,false) end
   if s.tick>=s.fireAt then
    arrow_lanes(c,s.aim,{0},.95,true); s.fireAt=nil; s.payloadUntil=s.tick+60; s.busyUntil=s.tick+130
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Saboteur Instructor: &fYou noticed the fuse. Keep noticing it.'); return
  end
  if s.tick>=s.nextBeacon and not s.beacon then
   s.nextBeacon=s.tick+440; s.snarePosition=player:get_location(); s.snare=ground_circle(c,s.snarePosition,2.5)
   s.plantAt=s.tick+34; c.boss:play_sound_at_self('BLOCK_TRIPWIRE_ATTACH',.5,.8)
  elseif s.tick>=s.nextPayload then
   s.nextPayload=s.tick+360; s.fireAt=s.tick+36; s.lockAt=s.tick+22; s.aim=player:get_eye_location()
   s.snaresPausedUntil=s.tick+170; c.boss:play_sound_at_self('ITEM_CROSSBOW_LOADING_START',.6,.7)
  end
 end,
 on_player_damaged_by_boss=function(c)
  if not c.event.projectile then return end
  c.event.multiply_damage_amount(.25)
  local s=c.state
  if (s.payloadUntil or 0)>(s.tick or 0) then
   s.payloadUntil=0
   local player=c.players:current_target()
   if player then c.scheduler:run_later(10,function()
    if player:is_alive() then powder_charge(c,player:get_location(),36,.6) end
   end) end
  end
 end,
 on_death=function(c) c.boss:send_message('&6Saboteur Instructor: &fBoth warnings answered. Nothing left to disarm.',24) end
}
