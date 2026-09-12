-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc
-- @include abilities/arcane_bolt.inc

-- Two finite familiar summons. The binding sigil is an ordinary destructible
-- reinforcement, and its protection only reaches a familiar inside its circle.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.charges=2; s.nextPortal=45; s.nextSigil=0; s.nextBolt=170
   player:send_message('&6Summoner Instructor: &fA familiar needs a bond. The sigil shows how far mine reaches.')
  end
  if s.familiar and (not s.familiar:is_alive() or s.tick>=s.familiarUntil) then
   if s.familiar:is_alive() then s.familiar:remove_elite() end
   s.familiar=nil
   if s.sigil and s.sigil:is_alive() then s.sigil:remove_elite() end; s.sigil=nil; s.sigilAt=nil
  end
  if s.sigil then
   if not s.sigil:is_alive() or s.tick>=s.sigilUntil then
    local broken=not s.sigil:is_alive(); if not broken then s.sigil:remove_elite() end
    s.sigil=nil
    if broken then s.busyUntil=s.tick+60; pause_movement(c,60) end
   elseif s.tick%5==0 then show_circle(c,s.circle,220,190,110) end
  end
  if s.portalAt then
   if s.tick%4==0 then show_circle(c,s.marker,170,120,245) end
   if s.tick>=s.portalAt then
    s.portalAt=nil; s.familiar=c.world:spawn_custom_boss_at_location('class_trial_arcane_familiar.yml',s.anchor,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.familiar,'Arcane Familiar could not spawn'); s.familiarUntil=s.tick+240; s.busyUntil=s.tick+40
   end
   return
  end
  if s.sigilAt then
   if s.tick%4==0 then show_circle(c,s.circle,220,190,110) end
   if s.tick>=s.sigilAt then
    s.sigilAt=nil; s.sigil=c.world:spawn_custom_boss_at_location('class_trial_binding_sigil.yml',s.sigilPosition,
     {level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(s.sigil,'Binding Sigil could not spawn'); s.sigilUntil=s.tick+120; s.busyUntil=s.tick+40
   end
   return
  end
  if s.boltAt then
   if s.tick%4==0 then spell_aim(c,s.aim) end
   if s.tick>=s.boltAt then spell_bolt(c,s.aim,.7); s.boltAt=nil; s.busyUntil=s.tick+80 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Summoner Instructor: &fChanging my position need not change your purpose. Watch the bond.')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  if not s.familiar and s.charges>0 and s.tick>=s.nextPortal then
   s.charges=s.charges-1; s.nextPortal=s.tick+520; local p=c.boss:get_location()
   s.anchor={world=p.world,x=p.x+3,y=p.y,z=p.z+2}; s.marker=ground_circle(c,s.anchor,1.2)
   s.portalAt=s.tick+40; pause_movement(c,80); c.boss:play_sound_at_self('BLOCK_PORTAL_AMBIENT',.5,1.4)
  elseif s.familiar and not s.sigil and s.tick>=s.nextSigil then
   s.nextSigil=s.tick+440; local p,q=c.boss:get_location(),s.familiar:get_location()
   s.sigilPosition={world=p.world,x=(p.x+q.x)/2,y=p.y,z=(p.z+q.z)/2}; s.circle=ground_circle(c,s.sigilPosition,5)
   s.sigilAt=s.tick+32; pause_movement(c,72)
  elseif s.tick>=s.nextBolt then
   s.nextBolt=s.tick+180; s.boltAt=s.tick+30; s.aim=player:get_eye_location(); pause_movement(c,110)
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if s.familiar and s.sigil and s.sigil:is_alive() and c.event.entity.uuid==s.familiar.uuid
    and s.circle:contains(s.familiar:get_location()) then c.event.multiply_damage_amount(.65) end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.3) end end,
 on_death=function(c) c.boss:send_message('&6Summoner Instructor: &fYou saw the strength of the bond, and its limits. Remember both.',24) end
}
