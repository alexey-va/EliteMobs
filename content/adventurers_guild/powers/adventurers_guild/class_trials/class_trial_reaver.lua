-- @include ground_markers.inc
-- @include mobility/leap_slam.inc
-- @include abilities/three_swing_drill.inc
-- @include abilities/blood_scent.inc

return {
 api_version=1,
 on_spawn=function(c) c.state.healingLeft=c.boss:get_maximum_health()*.12 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextScent=40; s.nextFeast=130
   player:send_message('&6Reaver Instructor: &fEvery cut feeds me. Leave the blade hungry.')
  end
  show_blood_scent(c,player)
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Reaver Instructor: &fThe hunger sharpens. Do not give it an answer.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextScent then s.nextScent=s.tick+360; blood_scent(c,100)
  elseif s.tick>=s.nextFeast then
   s.nextFeast=s.tick+340; s.feastUntil=s.tick+94; s.fed=false
   three_swing_drill(c,player,{32,26,28},{.25,.3,.35})
  end
 end,
 on_player_damaged_by_boss=function(c)
  local s=c.state
  if (s.feastUntil or 0)>(s.tick or 0) and not s.fed then
   s.fed=true
   local amount=math.min(s.healingLeft,c.boss:get_maximum_health()*.02,c.boss:get_maximum_health()-c.boss:get_health())
   if amount>0 then c.boss:restore_health(amount); s.healingLeft=s.healingLeft-amount end
   c.boss:spawn_particle_at_self({particle='DUST',red=190,green=45,blue=45,amount=5},1)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Reaver Instructor: &fEmpty air. You kept the hunger mine.',24) end
}
