-- @include ground_markers.inc
-- @include mobility/windstep.inc
-- @include abilities/arrow_lanes.inc

return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.effigies={}
  for i=1,2 do
   local actor=c.world:spawn_custom_boss_at_location('class_trial_armored_effigy.yml',
    {world=p.world,x=p.x+(i==1 and -4 or 4),y=p.y,z=p.z+5},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(actor,'Dragonslayer effigy could not spawn'); c.state.effigies[i]=actor
  end
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextMark=40; s.nextPiercer=120
   player:send_message('&6Dragonslayer Instructor: &fThat giant gives me a steady brace. Remove it before the shot.')
  end
  if s.marked and s.marked:is_alive() and s.tick%5==0 then show_circle(c,ground_circle(c,s.marked:get_location(),1.2),240,210,130) end
  if s.fireAt then
   if s.brace and not s.brace:is_alive() then
    s.fireAt=nil; s.brace=nil; s.busyUntil=s.tick+70; s.exposedUntil=s.tick+70
    player:send_message('&6Dragonslayer Instructor: &fYou took away the support before the shot.'); return
   end
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   if s.tick%4==0 then arrow_lanes(c,s.aim,{0},1.4,false) end
   if s.tick>=s.fireAt then
    arrow_lanes(c,s.aim,{0},1.4,true); s.fireAt=nil; s.brace=nil; s.busyUntil=s.tick+130; s.exposedUntil=s.tick+130
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Dragonslayer Instructor: &fThe second giant offers the same weakness.'); return
  end
  if s.tick>=s.nextMark then
   s.nextMark=s.tick+480; s.busyUntil=s.tick+50; s.marked=nil
   for _,actor in ipairs(s.effigies) do if actor:is_alive() then s.marked=actor; if not s.phaseTwo then break end end end
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_FLUTE',.6,1.3)
  elseif s.tick>=s.nextPiercer then
   s.nextPiercer=s.tick+400; s.brace=s.marked and s.marked:is_alive() and s.marked or nil
   s.shotDamage=s.brace and 1.2 or .65; s.fireAt=s.tick+48; s.lockAt=s.tick+28; s.aim=player:get_eye_location()
   c.boss:play_sound_at_self('ITEM_CROSSBOW_LOADING_START',.6,.5)
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(c.state.shotDamage or .65) end end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.25) end
 end,
 on_death=function(c) c.boss:send_message('&6Dragonslayer Instructor: &fYou chose the weak point before you chose the shot. Good.',24) end
}
