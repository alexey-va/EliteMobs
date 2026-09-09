-- @include ground_markers.inc
-- @include mobility/leap_slam.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextChain=80; s.nextRoar=40
   player:send_message('&6Dreadnought Instructor: &fThree rings. Cross each one after it falls.')
  end
  if s.ringAt then
   if s.tick%4==0 then show_circle(c,s.ring,205,150,100); show_circle(c,s.inside,245,220,150) end
   if s.tick>=s.ringAt then
    local q=player:get_location()
    if s.ring:contains(q) and not s.inside:contains(q) then
     c.script:damage(ground_circle(c,q,.5):full_target(),1,.4)
    end
    c.boss:play_sound_at_self('ENTITY_GENERIC_EXPLODE',.5,.6+s.ringIndex*.15)
    s.ringIndex=s.ringIndex+1
    if s.ringIndex>3 then s.ringAt=nil; s.busyUntil=s.tick+60; s.exposedUntil=s.tick+60
    else
     s.ringAt=s.tick+22; s.ring=ground_circle(c,s.center,s.ringIndex*2)
     s.inside=ground_circle(c,s.center,s.ringIndex*2-1.2)
    end
   end
   return
  end
  if (s.ironUntil or 0)>s.tick and s.tick%10==0 then c.boss:spawn_particle_at_self({particle='WAX_ON',amount=3},1) end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Dreadnought Instructor: &fThe ground remembers every blow. Keep moving between them.')
   if leap_slam(c,player) then s.busyUntil=s.tick+100; return end
  end
  if s.tick>=s.nextRoar then
   s.nextRoar=s.tick+400; s.busyUntil=s.tick+58; pause_movement(c,58)
   c.boss:play_sound_at_self('ENTITY_RAVAGER_ROAR',.6,.6)
   c.scheduler:run_later(28,function() s.ironUntil=s.tick+100 end)
  elseif s.tick>=s.nextChain then
   s.nextChain=s.tick+440; s.center=c.boss:get_location(); s.ringIndex=1
   s.ring=ground_circle(c,s.center,2); s.inside=ground_circle(c,s.center,.8); s.ringAt=s.tick+36
   pause_movement(c,140); c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_BASEDRUM',.6,.5)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if c.event.is_damage_transfer then return end
  if (c.state.ironUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(.7) end
  if (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_death=function(c) c.boss:send_message('&6Dreadnought Instructor: &fYou found quiet ground in the middle of that. Well fought.',24) end
}
