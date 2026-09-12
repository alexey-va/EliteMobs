-- @include ground_markers.inc
-- @include mobility/windstep.inc
-- @include abilities/arrow_lanes.inc
-- @include abilities/powder_charge.inc

-- Cluster charges land on the committed marked ground. They have separate,
-- staggered fuses and ordinary destructible bodies, rather than fake impacts.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextMarker=40; s.nextCluster=140
   player:send_message('&6Demolitionist Instructor: &fThe bolt is only the beginning. Count the fuses after it lands.')
  end
  if (s.markerUntil or 0)>s.tick and not s.markerSpent and s.tick%5==0 then show_circle(c,s.marker,245,180,70) end
  if s.markAt then
   if s.tick%4==0 then show_circle(c,s.marker,245,180,70) end
   if s.tick>=s.markAt then s.markAt=nil; s.markerUntil=s.tick+180; s.markerSpent=false; s.busyUntil=s.tick+20 end
   return
  end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); s.landing=player:get_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then
    arrow_lanes(c,s.aim,{0},.95,false); show_circle(c,ground_circle(c,s.landing,1.6),245,180,70)
   end
   if s.tick>=s.fireAt then
    arrow_lanes(c,s.aim,{0},.95,true); s.fireAt=nil; s.busyUntil=s.tick+150
    local landing=s.landing
    c.scheduler:run_later(20,function()
     for i,offset in ipairs({{0,0},{-3.5,2.5},{3.5,2.5}}) do
      local point={world=landing.world,x=landing.x+offset[1],y=landing.y,z=landing.z+offset[2]}
      local boost=(s.markerUntil or 0)>s.tick and not s.markerSpent and s.marker:contains(point)
      if boost then s.markerSpent=true end
      powder_charge(c,point,16+16*i,boost and .45 or .35)
     end
    end)
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Demolitionist Instructor: &fPlenty of room between those canisters. Use it.'); return
  end
  if s.tick>=s.nextMarker then
   s.nextMarker=s.tick+440; s.marker=ground_circle(c,player:get_location(),1.5); s.markAt=s.tick+32
   c.boss:play_sound_at_self('BLOCK_ANVIL_PLACE',.5,1.4)
  elseif s.tick>=s.nextCluster then
   s.nextCluster=s.tick+480; s.fireAt=s.tick+40; s.lockAt=s.tick+24; s.aim=player:get_eye_location(); s.landing=player:get_location()
   c.boss:play_sound_at_self('ITEM_CROSSBOW_LOADING_START',.6,.7)
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.2) end end,
 on_death=function(c) c.boss:send_message('&6Demolitionist Instructor: &fYou left nothing burning. I appreciate a tidy finish.',24) end
}
