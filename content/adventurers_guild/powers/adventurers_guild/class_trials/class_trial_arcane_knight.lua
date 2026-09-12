-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc

return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.cadet=c.world:spawn_custom_boss_at_location('class_trial_arcane_cadet.yml',
   {world=p.world,x=p.x+3,y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.cadet,'Arcane cadet could not spawn')
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextAegis=45; s.nextBreaker=130
   player:send_message('&6Arcane Knight Instructor: &fThe aegis reaches my cadet only while we stand together.')
  end
  if (s.wardUntil or 0)<=s.tick then s.ward=0; s.cadetWard=0 end
  if (s.ward or 0)>0 and s.tick%6==0 then c.boss:spawn_particle_at_self({particle='ENCHANT',amount=6},1) end
  if s.aegisAt then
   if s.tick%4==0 then show_circle(c,s.circle,170,120,245) end
   if s.tick>=s.aegisAt then
    s.aegisAt=nil; s.ward=c.boss:get_maximum_health()*.04; s.wardUntil=s.tick+100
    if s.cadet:is_alive() and s.circle:contains(s.cadet:get_location()) then s.cadetWard=s.cadet:get_maximum_health()*.25 end
    s.busyUntil=s.tick+50
   end
   return
  end
  if s.breakerAt then
   if s.tick%3==0 then show_circle(c,s.line,190,130,245) end
   if s.tick>=s.breakerAt then
    c.script:damage(s.line:full_target(),1,.8)
    local p=player:get_location(); p.y=p.y+.75
    if s.line:contains(p) then player:apply_potion_effect('WEAKNESS',40,0) end
    s.breakerAt=nil; s.busyUntil=s.tick+56
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Arcane Knight Instructor: &fHold your ground. I will find another line through it.')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  if s.tick>=s.nextAegis then
   s.nextAegis=s.tick+440; s.aegisAt=s.tick+36; s.channelDamage=0; s.circle=ground_circle(c,c.boss:get_location(),5)
   pause_movement(c,86); c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_RESONATE',.6,.8)
  elseif s.tick>=s.nextBreaker then
   s.nextBreaker=s.tick+360; s.breakerAt=s.tick+30
   s.line=forward_cone(c,c.boss:get_location(),player:get_location(),7,1); pause_movement(c,86)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state; local amount=c.event.get_damage_amount()
  if (s.ward or 0)>0 and amount>0 then
   local used=math.min(amount,s.ward); s.ward=s.ward-used; c.event.multiply_damage_amount((amount-used)/amount)
  end
  if s.aegisAt and not c.event.is_damage_transfer then
   s.channelDamage=s.channelDamage+c.event.get_damage_amount()
   if s.channelDamage>=c.boss:get_maximum_health()*.025 then
    s.aegisAt=nil; s.busyUntil=(s.tick or 0)+60; pause_movement(c,60)
    c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.2)
   end
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state; local amount=c.event.get_damage_amount()
  if s.cadet and c.event.entity.uuid==s.cadet.uuid and (s.cadetWard or 0)>0 and amount>0 then
   local used=math.min(amount,s.cadetWard); s.cadetWard=s.cadetWard-used; c.event.multiply_damage_amount((amount-used)/amount)
  end
 end,
 on_death=function(c) c.boss:send_message('&6Arcane Knight Instructor: &fYou understood both the blade and the duty behind it.',24) end
}
