-- @include ground_markers.inc
-- @include mobility/steed_charge.inc

-- Expose marks the next committed sentence. Sidestepping the locked narrow lane
-- breaks the mark. Low health makes the sentence stronger, never unavoidable.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextMark=60; s.nextSentence=120
   player:send_message('&6Inquisitor Instructor: &fI need an opening. Do not offer me one.')
  end
  if (s.markUntil or 0)>s.tick and s.tick%10==0 then
   c.world:spawn_particle_at_location(player:get_eye_location(),{particle='DUST',red=245,green=190,blue=60,amount=3},3)
  end
  if s.sentenceAt then
   if s.tick<s.lockAt then
    s.lane=forward_cone(c,c.boss:get_location(),player:get_location(),7,.8)
    c.boss:face_direction_or_location(player:get_location())
   end
   if s.tick%4==0 then show_circle(c,s.lane,235,160,60) end
   if s.tick>=s.sentenceAt then
    local p=player:get_location(); p.y=p.y+.75
    local hits=s.lane:contains(p)
    local low=player:get_health()<player:get_maximum_health()*.35
    c.script:damage(s.lane:full_target(),1,low and 1.05 or .9)
    if not hits then
     s.markUntil=0
     player:send_message('&6Inquisitor Instructor: &fNo opening. No sentence.')
    end
    c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.55,.8)
    s.sentenceAt=nil; s.busyUntil=s.tick+60
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.busyUntil=s.tick+65; s.nextMark=s.tick+65
   player:send_message('&6Inquisitor Instructor: &fYou read the charge. Now read what follows.')
   steed_charge(c,player)
  elseif s.tick>=s.nextMark then
   s.nextMark=s.tick+360; s.busyUntil=s.tick+24
   c.boss:play_sound_at_self('BLOCK_ENCHANTMENT_TABLE_USE',.5,.7)
   c.scheduler:run_later(24,function() s.markUntil=s.tick+120 end)
  elseif s.tick>=s.nextSentence then
   s.nextSentence=s.tick+320; s.sentenceAt=s.tick+36; s.lockAt=s.tick+22
   s.lane=forward_cone(c,c.boss:get_location(),player:get_location(),7,.8)
   pause_movement(c,96); c.boss:play_sound_at_self('BLOCK_ANVIL_PLACE',.5,1.3)
  end
 end,
 on_player_damaged_by_boss=function(c)
  if (c.state.markUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.15) end
 end,
 on_death=function(c) c.boss:send_message('&6Inquisitor Instructor: &fYou gave me nothing to condemn. A satisfactory lesson.',24) end
}
