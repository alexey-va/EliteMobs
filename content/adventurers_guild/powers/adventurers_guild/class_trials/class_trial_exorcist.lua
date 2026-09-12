-- @include ground_markers.inc
-- @include cleric_support.inc
-- @include mobility/radiant_flight.inc

-- Smite commits to a narrow line. Its ordinary hit event feeds Succor, so a
-- dodge denies healing. Banish gives a separate cone warning before push/weakness.
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.attendant=c.world:spawn_custom_boss_at_location('class_trial_exorcist_attendant.yml',
   {world=p.world,x=p.x+3,y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.attendant,'Exorcist attendant could not spawn')
  c.state.healingLeft=c.boss:get_maximum_health()*.1
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextSmite=50; s.nextBanish=210
   player:send_message('&6Exorcist Instructor: &fStep out of the line. A missed smite brings no succor.')
  end
  if s.smiteAt then
   if s.tick%4==0 then show_circle(c,s.zone,245,190,100) end
   if s.tick>=s.smiteAt then
    s.smiting=true; c.script:damage(s.zone:full_target(),1,.8); s.smiting=false
    s.smiteAt=nil; s.restUntil=s.tick+60
    c.boss:play_sound_at_self('ENTITY_LIGHTNING_BOLT_IMPACT',.4,1.2)
   end
   return
  end
  if s.banishAt then
   if s.tick%4==0 then show_circle(c,s.zone,245,220,150) end
   if s.tick>=s.banishAt then
    local position=player:get_location(); position.y=position.y+.75
    if s.zone:contains(position) then
     player:push_relative_to(c.boss:get_location(),.3,0,.1,0)
     player:apply_potion_effect('WEAKNESS',40,0)
    end
    s.banishAt=nil; s.restUntil=s.tick+30
   end
   return
  end
  if s.tick<(s.restUntil or 0) then return end
  if s.restUntil then s.restUntil=nil; c.boss:set_ai_enabled(true) end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true
   player:send_message('&6Exorcist Instructor: &fKeep your footing. I will make room for the wounded.')
   if s.attendant:is_alive() and radiant_flight(c,s.attendant:get_location()) then s.restUntil=s.tick+60; return end
  end
  if s.tick>=s.nextBanish then
   s.nextBanish=s.tick+400; s.zone=forward_cone(c,c.boss:get_location(),player:get_location(),4,2.8)
   s.banishAt=s.tick+30; c.boss:set_ai_enabled(false)
   c.boss:play_sound_at_self('BLOCK_BELL_USE',.6,.7)
  elseif s.tick>=s.nextSmite then
   s.nextSmite=s.tick+360; s.zone=forward_cone(c,c.boss:get_location(),player:get_location(),6,.85)
   s.smiteAt=s.tick+32; c.boss:set_ai_enabled(false)
   c.boss:play_sound_at_self('BLOCK_BELL_USE',.6,1.2)
  end
 end,
 on_player_damaged_by_boss=function(c)
  if c.state.smiting and c.event.get_damage_amount()>0 then
   cleric_heal(c,c.state.attendant,.2)
  end
 end,
 on_death=function(c)
  c.boss:send_message('&6Exorcist Instructor: &fYou denied the strike and spared yourself the burden. Well judged.',24)
 end
}
