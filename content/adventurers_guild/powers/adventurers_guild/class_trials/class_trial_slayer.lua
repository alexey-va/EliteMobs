-- @include ground_markers.inc
-- @include mobility/leap_slam.inc
-- @include abilities/three_swing_drill.inc
-- @include abilities/blood_scent.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextHunt=40; s.nextRhythm=130
   player:send_message('&6Slayer Instructor: &fThe last stroke is the dangerous one. Save room for it.')
  end
  show_blood_scent(c,player)
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Slayer Instructor: &fI can smell an opening. Make sure it is mine.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextHunt then s.nextHunt=s.tick+400; blood_scent(c,100)
  elseif s.tick>=s.nextRhythm then
   s.nextRhythm=s.tick+350
   local finish=player:get_health()<player:get_maximum_health()*.35 and .65 or .5
   three_swing_drill(c,player,{28,30,40},{.25,.3,finish})
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Slayer Instructor: &fNo finish there. You kept your feet.',24) end
}
