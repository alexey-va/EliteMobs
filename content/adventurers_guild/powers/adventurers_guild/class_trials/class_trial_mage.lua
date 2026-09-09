-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc
-- @include abilities/arcane_bolt.inc

-- Three aimed bolts leave time to move between releases. Prepared Spell Echo
-- creates a destructible crystal that repeats the last aim after 24 ticks.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextVolley=90; s.nextEcho=35; s.nextBlink=300
   player:send_message('&6Mage Instructor: &fThree spells, then an echo. The crystal remembers only the last aim.')
  end
  if s.focus then
   if not s.focus:is_alive() then s.focus=nil
   elseif s.tick>=s.echoAt then
    c.boss:summon_projectile('SNOWBALL',s.focus:get_eye_location(),s.echoAim,.8,
     {gravity=false,persistent=false,spawn_at_origin=true,duration=60})
    s.focus:remove_elite(); s.focus=nil
   elseif s.tick%4==0 then s.focus:spawn_particle_at_self({particle='ENCHANT',amount=5},1) end
  end
  if s.fireAt then
   if s.tick<s.fireAt-8 then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then spell_aim(c,s.aim) end
   if s.tick>=s.fireAt then
    spell_bolt(c,s.aim,.8); s.remaining=s.remaining-1
    if s.remaining>0 then s.fireAt=s.tick+16
    else
     s.fireAt=nil; s.busyUntil=s.tick+110
     if s.echoReady then
      s.echoReady=false; local p=c.boss:get_location()
      s.focus=c.world:spawn_custom_boss_at_location('class_trial_spell_echo.yml',
       {world=p.world,x=p.x+1,y=p.y,z=p.z},{level=c.boss.level,add_as_reinforcement=true,silent=true})
      assert(s.focus,'Spell Echo could not spawn'); s.echoAim=s.aim; s.echoAt=s.tick+24
     end
    end
   end
   return
  end
  if s.prepareAt then
   if s.tick%4==0 then c.boss:spawn_particle_at_self({particle='ENCHANT',amount=6},1) end
   if s.tick>=s.prepareAt then s.prepareAt=nil; s.echoReady=true; s.busyUntil=s.tick+12 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.nextBlink=s.tick
   player:send_message('&6Mage Instructor: &fA fresh angle. Do not let the echo draw you back into the line.')
  end
  if s.tick>=s.nextBlink then
   s.nextBlink=s.tick+300; if arcane_blink(c,player) then s.busyUntil=s.tick+46 end
  elseif s.tick>=s.nextEcho and not s.echoReady then
   s.nextEcho=s.tick+440; s.prepareAt=s.tick+28; pause_movement(c,40)
   c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,1.6)
  elseif s.tick>=s.nextVolley then
   s.nextVolley=s.tick+280; s.remaining=3; s.fireAt=s.tick+30; s.aim=player:get_eye_location(); pause_movement(c,172)
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.35) end end,
 on_death=function(c) c.boss:send_message('&6Mage Instructor: &fYou followed the spell beyond its first answer. Well observed.',24) end
}
