-- @include ground_markers.inc
-- @include mobility/leap_slam.inc
-- @include abilities/three_swing_drill.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextRoar=45; s.nextFrenzy=140
   player:send_message('&6Bloodrager Instructor: &fHear that breath? Interrupt it before I spend it.')
  end
  if s.roarAt then
   if s.tick%4==0 then c.boss:spawn_particle_at_self({particle='DUST',red=200,green=45,blue=45,amount=3},1) end
   if s.tick>=s.roarAt then s.roarAt=nil; s.fuel=true; s.busyUntil=s.tick+30 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Bloodrager Instructor: &fNow it burns. Let it burn itself out.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextRoar then
   s.nextRoar=s.tick+400; s.roarAt=s.tick+32; s.pressure=0; pause_movement(c,62)
   c.boss:play_sound_at_self('ENTITY_RAVAGER_ROAR',.6,.7)
  elseif s.tick>=s.nextFrenzy then
   s.nextFrenzy=s.tick+360
   local strength=s.phaseTwo and s.fuel and .4 or .3
   s.frenzyUntil=s.tick+98; s.fuel=false
   three_swing_drill(c,player,{30,30,30},{strength,strength,strength})
  end
 end,
 on_boss_damaged_by_player=function(c)
  if c.event.is_damage_transfer then return end
  local s=c.state
  if s.roarAt then
   s.pressure=s.pressure+c.event.get_damage_amount()
   if s.pressure>=c.boss:get_maximum_health()*.035 then
    s.roarAt=nil; s.fuel=false; s.busyUntil=s.tick+40; pause_movement(c,40)
    c.boss:send_message('&6Bloodrager Instructor: &fCaught my breath before I could spend it.',24)
    c.boss:play_sound_at_self('ENTITY_PLAYER_BREATH',.5,.7)
   end
  end
  if (s.frenzyUntil or 0)>(s.tick or 0) or (s.exposedUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Bloodrager Instructor: &fAll that fury, and you kept your head. That is the lesson.',24) end
}
