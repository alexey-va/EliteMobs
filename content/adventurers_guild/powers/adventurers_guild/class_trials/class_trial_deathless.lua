-- @include ground_markers.inc
-- @include mobility/leap_slam.inc

-- One refused fatal strike, followed by a finite eight-percent recovery.
-- All later damage uses the ordinary event path. The rune never rearms.
return {
 api_version=1,
 on_spawn=function(c) c.state.roars=0 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextRoar=60
   player:send_message('&6Deathless Instructor: &fOne breath can turn a fight. Do not waste yours chasing the first ending.')
  end
  if not s.spent and s.tick%10==0 then c.boss:spawn_particle_at_self({particle='TOTEM_OF_UNDYING',amount=1},1) end
  if s.roarAt then
   if s.tick%4==0 then show_circle(c,ground_circle(c,c.boss:get_location(),1.5),210,80,65) end
   if s.tick>=s.roarAt then
    s.roarAt=nil; s.roars=s.roars+1; s.guardUntil=s.tick+80; s.busyUntil=s.tick+50
    c.boss:restore_health(c.boss:get_maximum_health()*.02)
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Deathless Instructor: &fStill breathing. So are you. Keep at it.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.roars<2 and s.tick>=s.nextRoar then
   s.nextRoar=s.tick+480; s.roarAt=s.tick+40; s.pressure=0; pause_movement(c,90)
   c.boss:play_sound_at_self('ENTITY_PLAYER_BREATH',.6,.6)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if (s.lastBreathUntil or 0)>(s.tick or 0) then c.event.cancel_event(); return end
  if c.event.is_damage_transfer then return end
  if not s.spent and c.event.get_damage_amount()>=c.boss:get_health() then
   s.spent=true; s.roarAt=nil; s.lastBreathUntil=(s.tick or 0)+40; s.busyUntil=(s.tick or 0)+80
   c.event.cancel_event(); pause_movement(c,80)
   c.boss:play_sound_at_self('ITEM_TOTEM_USE',.6,.8)
   c.boss:send_message('&6Deathless Instructor: &fOne breath left. Watch what I do with it.',24)
   for i=1,4 do c.scheduler:run_later(i*10,function() c.boss:restore_health(c.boss:get_maximum_health()*.02) end) end
   return
  end
  if (s.guardUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(.6) end
  if s.roarAt then
   s.pressure=s.pressure+c.event.get_damage_amount()
   if s.pressure>=c.boss:get_maximum_health()*.035 then
    s.roarAt=nil; s.roars=s.roars+1; s.busyUntil=s.tick+40; pause_movement(c,40)
    c.boss:send_message('&6Deathless Instructor: &fBreath lost. Opening found.',24)
   end
  end
 end,
 on_death=function(c) c.boss:send_message('&6Deathless Instructor: &fThere. You saw the fight through to its true end.',24) end
}
