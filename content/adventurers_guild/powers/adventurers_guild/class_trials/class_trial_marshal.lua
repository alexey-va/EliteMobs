-- @include ground_markers.inc
-- @include mobility/steed_charge.inc
-- @include abilities/battle_standard.inc

return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.lancer=c.world:spawn_custom_boss_at_location('class_trial_guild_lancer.yml',
   {x=p.x+3,y=p.y,z=p.z+2,world=p.world},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.lancer,'Marshal lancer could not spawn')
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextStandard=60; s.nextReform=200
   player:send_message('&6Marshal Instructor: &fThe standard is our advantage. You know what to do with it.')
  end
  if s.standard then
   if not s.standard:is_alive() then
    s.standard=nil; s.exposedUntil=s.tick+60
    player:send_message('&6Marshal Instructor: &fThe standard falls. Our advantage falls with it.')
   elseif s.tick>=s.standardUntil then s.standard:remove_elite(); s.standard=nil
   elseif s.tick%5==0 then show_circle(c,s.standardZone,245,210,110) end
  end
  if s.plantAt then
   if s.tick%4==0 then show_circle(c,s.plantZone,245,210,110) end
   if s.tick>=s.plantAt then
    s.standard=c.world:spawn_custom_boss_at_location('class_trial_battle_standard.yml',s.plantLocation,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.standard,'Marshal standard could not spawn')
    s.standardZone=s.plantZone; s.standardUntil=s.tick+160; s.plantAt=nil; s.busyUntil=s.tick+30
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.busyUntil=s.tick+65; steed_charge(c,player)
   player:send_message('&6Marshal Instructor: &fReform on me. You have one moment to disrupt us.')
  elseif s.tick>=s.nextStandard and not banner_alive(s) then
   local p=c.boss:get_location()
   s.plantLocation={x=p.x+2,y=p.y,z=p.z,world=p.world}; s.plantZone=ground_circle(c,s.plantLocation,5)
   s.plantAt=s.tick+36; s.nextStandard=s.tick+480
   c.boss:play_sound_at_self('BLOCK_WOOD_PLACE',.5,.7)
  elseif s.tick>=s.nextReform and banner_alive(s) and s.lancer and s.lancer:is_alive() then
   s.nextReform=s.tick+360; s.reformingUntil=s.tick+60; s.busyUntil=s.tick+90
   c.boss:play_sound_at_self('ITEM_GOAT_HORN_SOUND_0',.5,1)
   local p=s.standard:get_location()
   c.boss:navigate_to_location({x=p.x-2,y=p.y,z=p.z,world=p.world},.8,false,60)
   s.lancer:navigate_to_location({x=p.x+2,y=p.y,z=p.z,world=p.world},.8,false,60)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if c.event.is_damage_transfer then return end
  if within_banner(c.state,c.boss) then c.event.multiply_damage_amount(.8) end
  if (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_reinforcement_damaged_by_player=function(c)
  if c.event.is_damage_transfer or not c.state.lancer or c.event.entity.uuid~=c.state.lancer.uuid then return end
  if within_banner(c.state,c.event.entity) then c.event.multiply_damage_amount(.8) end
 end,
 on_player_damaged_by_boss=function(c) if within_banner(c.state,c.boss) then c.event.multiply_damage_amount(1.2) end end,
 on_death=function(c) c.boss:send_message('&6Marshal Instructor: &fYou broke the formation, not your focus. Well done.',24) end
}
