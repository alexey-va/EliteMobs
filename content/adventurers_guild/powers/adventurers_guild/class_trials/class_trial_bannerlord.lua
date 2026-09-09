-- @include ground_markers.inc
-- @include mobility/steed_charge.inc

return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.cadets={}
  for _,side in ipairs({-1,1}) do
   local cadet=c.world:spawn_custom_boss_at_location('class_trial_guardian_apprentice.yml',
    {x=p.x+side*3,y=p.y,z=p.z+2,world=p.world},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(cadet,'Bannerlord cadet could not spawn'); table.insert(c.state.cadets,cadet)
  end
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextStandard=70; s.nextAdvance=140
   player:send_message('&6Bannerlord Instructor: &fThe banner moves with us. Draw my companions beyond its reach.')
  end
  if s.standardUntil and s.standardUntil>s.tick then
   if s.tick%5==0 then
    s.aura=ground_circle(c,c.boss:get_location(),4)
    show_circle(c,s.aura,245,225,170)
   end
  elseif s.standardUntil then
   s.standardUntil=nil; s.exposedUntil=s.tick+60
   pause_movement(c,60)
   player:send_message('&6Bannerlord Instructor: &fEven a standard must be lowered. Now is your moment.')
  end
  if s.tick<(s.busyUntil or 0) or s.tick<(s.exposedUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.busyUntil=s.tick+65; steed_charge(c,player)
   player:send_message('&6Bannerlord Instructor: &fKeep the banner in sight. The line is advancing.')
  elseif s.tick>=s.nextStandard then
   s.nextStandard=s.tick+440; s.busyUntil=s.tick+30
   c.boss:play_sound_at_self('ITEM_ARMOR_EQUIP_LEATHER',.5,.7)
   c.scheduler:run_later(30,function() s.standardUntil=s.tick+160 end)
  elseif s.tick>=s.nextAdvance and s.standardUntil then
   s.nextAdvance=s.tick+360; s.busyUntil=s.tick+80
   local p,q=c.boss:get_location(),player:get_location()
   c.boss:play_sound_at_self('ITEM_GOAT_HORN_SOUND_0',.5,.7)
   c.boss:navigate_to_location(q,.65,false,80)
   for i,cadet in ipairs(s.cadets) do
    if cadet:is_alive() then cadet:navigate_to_location({x=q.x+(i==1 and -2 or 2),y=q.y,z=q.z,world=q.world},.7,false,80) end
   end
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if (s.standardUntil or 0)>(s.tick or 0) and s.aura and s.aura:contains(c.event.entity:get_location()) then c.event.multiply_damage_amount(.8) end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.event.is_damage_transfer and (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Bannerlord Instructor: &fYou saw the whole line. Carry that lesson with you.',24) end
}
