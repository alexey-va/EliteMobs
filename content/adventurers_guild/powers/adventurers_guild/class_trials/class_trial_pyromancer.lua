-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextBrazier=45
   player:send_message('&6Pyromancer Instructor: &fThe brazier feeds the flame. You can put an end to both.')
  end
  if s.brazier then
   if not s.brazier:is_alive() or s.tick>=s.brazierUntil then
    local broken=not s.brazier:is_alive()
    if not broken then s.brazier:remove_elite() end
    s.brazier=nil; s.fireUntil=0; s.igniteAt=nil
    if broken then
     s.exposedUntil=s.tick+60; s.busyUntil=s.tick+60; pause_movement(c,60)
     player:send_message('&6Pyromancer Instructor: &fThe source, exactly. Fire needs something to feed it.')
    end
   elseif (s.fireUntil or 0)>s.tick then
    if s.tick%4==0 then show_circle(c,s.fire,245,115,40) end
    if s.tick>=s.nextPulse then
     s.nextPulse=s.tick+20; c.script:damage(s.fire:full_target(),1,.25)
     s.brazier:spawn_particle_at_self({particle='FLAME',amount=8},1)
    end
   end
  end
  if s.summonAt then
   if s.tick%4==0 then show_circle(c,s.marker,245,180,80) end
   if s.tick>=s.summonAt then
    s.summonAt=nil; s.brazier=c.world:spawn_custom_boss_at_location('class_trial_ember_brazier.yml',s.anchor,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.brazier,'Ember Brazier could not spawn'); s.brazierUntil=s.tick+140; s.busyUntil=s.tick+12
   end
   return
  end
  if s.igniteAt then
   if s.tick%4==0 then show_circle(c,s.fire,245,115,40) end
   if s.tick>=s.igniteAt then
    s.igniteAt=nil; s.fireUntil=s.tick+80; s.brazierUntil=s.fireUntil; s.nextPulse=s.tick; s.busyUntil=s.tick+130
    if s.phaseTwo then arcane_blink(c,player) end
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Pyromancer Instructor: &fI can leave the fire behind. Can you?')
  end
  if s.brazier and (s.fireUntil or 0)<=s.tick then
   s.fire=ground_circle(c,s.anchor,4); s.igniteAt=s.tick+36; pause_movement(c,166)
   c.boss:play_sound_at_self('ITEM_FIRECHARGE_USE',.6,.8)
  elseif not s.brazier and s.tick>=s.nextBrazier then
   s.nextBrazier=s.tick+440; s.anchor=player:get_location(); s.marker=ground_circle(c,s.anchor,1)
   s.summonAt=s.tick+30; pause_movement(c,42)
   c.boss:play_sound_at_self('ENTITY_BLAZE_AMBIENT',.5,.8)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Pyromancer Instructor: &fYou kept your head while the ground burned. That matters more than heat.',24) end
}
