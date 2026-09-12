-- @include ground_markers.inc
-- @include mobility/steed_charge.inc
-- @include abilities/three_swing_drill.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextPress=50; s.nextRoar=220
   player:send_message('&6Conqueror Instructor: &fYield ground if you must. Never yield your timing.')
  end
  if s.roarAt then
   if s.tick%4==0 then show_circle(c,s.roar,220,145,70) end
   if s.tick>=s.roarAt then
    if s.roar:contains(player:get_location()) then
     player:apply_potion_effect('WEAKNESS',40,0)
     player:push_relative_to(c.boss:get_location(),-.18,0,.04,0)
    end
    s.roarAt=nil; s.busyUntil=s.tick+40
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.busyUntil=s.tick+65; steed_charge(c,player)
   player:send_message('&6Conqueror Instructor: &fI will press harder. Make each opening count.')
  elseif s.tick>=s.nextPress then
   s.nextPress=s.tick+330
   three_swing_drill(c,player,{28,22,30},{.35,.35,.4})
  elseif s.tick>=s.nextRoar then
   s.nextRoar=s.tick+380; s.roar=ground_circle(c,c.boss:get_location(),4)
   s.roarAt=s.tick+32; pause_movement(c,72)
   c.boss:play_sound_at_self('ENTITY_RAVAGER_ROAR',.6,.8)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Conqueror Instructor: &fYou held your nerve. That is harder to break than any shield.',24) end
}
