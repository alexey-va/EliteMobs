-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- Miracle is a single rescue with a long interrupt window. Hallowed Ground is
-- tied to a destructible candle, so pressure on its source stops the healing.
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.novice=c.world:spawn_custom_boss_at_location('class_trial_saint_novice.yml',
   {world=p.world,x=p.x+3,y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.novice,'Saint novice could not spawn')
  c.state.healingLeft=c.boss:get_maximum_health()*.15
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextGround=60
   player:send_message('&6Saint Instructor: &fWatch over the small light. Even a miracle needs time.')
  end
  if s.candle then
   if not s.candle:is_alive() or s.tick>=s.groundUntil then
    if s.candle:is_alive() then s.candle:remove_elite() end
    s.candle=nil; c.boss:play_sound_at_self('BLOCK_CANDLE_EXTINGUISH',.6,1)
   else
    if s.tick%5==0 then show_circle(c,s.ground,245,225,180) end
    if s.tick%20==0 then
     if cleric_in_circle(s.novice,s.anchor,4) then cleric_heal(c,s.novice,.04) end
     if not s.novice:is_alive() and cleric_in_circle(c.boss,s.anchor,4) then cleric_heal(c,c.boss,.005) end
    end
   end
  end
  if s.miracleAt then
   if s.novice:is_alive() and s.tick%4==0 then cleric_tether(c,c.boss,s.novice,false) end
   if s.tick>=s.miracleAt then
    cleric_heal(c,s.novice,.6); s.miracleAt=nil; s.restUntil=s.tick+60
    c.boss:play_sound_at_self('ITEM_TOTEM_USE',.5,1.4)
   end
   return
  end
  if s.groundAt then
   if s.tick%4==0 then show_circle(c,s.ground,245,225,180) end
   if s.tick>=s.groundAt then
    s.groundAt=nil
    s.candle=c.world:spawn_custom_boss_at_location('class_trial_prayer_candle.yml',s.anchor,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.candle,'Prayer Candle could not spawn')
    s.groundUntil=s.tick+120; s.restUntil=s.tick+40
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.miracleSpent and s.novice:is_alive()
    and s.novice:get_health()<s.novice:get_maximum_health()*.25 and s.healingLeft>0 then
   s.miracleSpent=true; s.miracleAt=s.tick+50; s.channelDamage=0
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_BEACON_AMBIENT',.6,1.4)
   player:send_message('&6Saint Instructor: &fStay with us. This prayer is spoken only once.')
  elseif not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Saint Instructor: &fA little light is enough, if we choose where to stand.')
   local anchor=s.novice:is_alive() and s.novice:get_location() or s.anchor
   if radiant_flight(c,anchor) then s.restUntil=s.tick+60 end
  elseif s.tick>=s.nextGround and not s.candle and s.healingLeft>0 then
   s.nextGround=s.tick+480
   local p=c.boss:get_location(); s.anchor={world=p.world,x=p.x+1,y=p.y,z=p.z}
   s.ground=ground_circle(c,s.anchor,4); s.groundAt=s.tick+32
   c.boss:set_ai_enabled(false); c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,1.4)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if not s.miracleAt or c.event.is_damage_transfer then return end
  s.channelDamage=s.channelDamage+c.event.get_damage_amount()
  if s.channelDamage>=c.boss:get_maximum_health()*.025 then
   s.miracleAt=nil; s.restUntil=s.tick+60
   c.boss:send_message('&6Saint Instructor: &fThe prayer was precious. You found its only opening.',24)
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.5)
  end
 end,
 on_death=function(c)
  c.boss:send_message('&6Saint Instructor: &fYou saw how fragile a rescue can be. Remember that when another needs yours.',24)
 end
}
