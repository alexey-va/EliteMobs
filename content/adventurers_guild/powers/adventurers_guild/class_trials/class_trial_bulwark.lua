-- @include ground_markers.inc
-- @include mobility/steed_charge.inc

-- Hold the Line fixes the shield's facing. Its slow repeated cleaves reward
-- circling. The ground ward only protects the instructor while it remains inside.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextLine=70; s.nextGround=240
   player:send_message('&6Bulwark Instructor: &fThis line will hold. Find the side it cannot cover.')
  end
  if s.groundUntil and s.groundUntil>s.tick and s.tick%5==0 then show_circle(c,s.ground,220,210,145) end
  if s.lineUntil then
   if s.tick%4==0 then show_circle(c,s.line,235,180,80) end
   if s.tick>=s.nextSwing then
    c.script:damage(s.line:full_target(),1,.6)
    c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.55,.65)
    s.nextSwing=s.tick+38
   end
   if s.tick>=s.lineUntil then s.lineUntil=nil; s.recoveryUntil=s.tick+50 end
   return
  end
  if s.tick<(s.recoveryUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.groundUntil=0; s.recoveryUntil=s.tick+65
   player:send_message('&6Bulwark Instructor: &fA wall that never moves becomes a prison. Make room.')
   steed_charge(c,player)
  elseif s.tick>=s.nextLine then
   s.nextLine=s.tick+360; s.lineUntil=s.tick+110; s.nextSwing=s.tick+34
   s.line=forward_cone(c,c.boss:get_location(),player:get_location(),3.5,2.1)
   c.boss:face_direction_or_location(player:get_location()); pause_movement(c,160)
   c.boss:play_sound_at_self('ITEM_SHIELD_BLOCK',.55,.5)
  elseif s.tick>=s.nextGround then
   s.nextGround=s.tick+440; s.groundUntil=s.tick+150
   s.ground=ground_circle(c,c.boss:get_location(),4)
   c.boss:play_sound_at_self('BLOCK_STONE_PLACE',.5,.6)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer then return end
  local player=c.players:current_target()
  local p=player and player:get_location(); if p then p.y=p.y+.75 end
  if s.lineUntil and p and s.line:contains(p) then c.event.multiply_damage_amount(.3) end
  if (s.groundUntil or 0)>(s.tick or 0) and s.ground:contains(c.boss:get_location()) then c.event.multiply_damage_amount(.75) end
  if (s.recoveryUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Bulwark Instructor: &fYou found the passage. Remember to leave one for those behind you.',24) end
}
