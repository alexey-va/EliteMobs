-- @include ground_markers.inc

-- A first lesson: dodge the marked strike, interrupt Second Wind, then use the
-- recovery window. There are no summons, stacking penalties or unavoidable hits.
return {
  api_version=1,
  on_game_tick=function(c)
    local player=c.boss:get_target_player()
    if not player or not player:is_alive() then return end
    local s=c.state; s.tick=(s.tick or 0)+1
    if not s.started then
      s.started=true; s.nextStrike=60
      player:send_message('&6Adventurer Instructor: &fWatch my feet. Step out of the mark, then strike.')
    end
    if s.breathUntil then
      if s.tick%5==0 then c.boss:spawn_particle_at_self({particle='HAPPY_VILLAGER',amount=3},3) end
      if s.tick>=s.breathUntil then
        s.breathUntil=nil; c.boss:restore_health(c.boss:get_maximum_health()*.08)
        c.boss:play_sound_at_self('ENTITY_PLAYER_LEVELUP',.5,1.6); s.nextStrike=s.tick+50
      end
      return
    end
    if not s.breathed and c.boss:get_health()<=c.boss:get_maximum_health()*.65 then
      s.breathed=true; s.breathUntil=s.tick+60; s.strikeAt=nil
      c.boss:set_ai_enabled(false,60)
      player:send_message('&6Adventurer Instructor: &fSecond Wind. A quick hit can stop mine.')
      c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_CHIME',.6,.8)
      return
    end
    if s.strikeAt then
      if s.tick%4==0 then show_circle(c,s.strike,240,190,80) end
      if s.tick>=s.strikeAt then
        c.script:damage(s.strike:full_target(),1,.3)
        c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.5,1)
        s.strikeAt=nil; s.nextStrike=s.tick+80
      end
      return
    end
    if s.tick<s.nextStrike then return end
    local p,q=c.boss:get_location(),player:get_location()
    if (p.x-q.x)^2+(p.z-q.z)^2>9 then
      c.boss:navigate_to_location(q,.65)
      s.nextStrike=s.tick+15
      return
    end
    if s.breathed and s.tick>=(s.nextDodge or 0) then
      local dx,dz=q.x-p.x,q.z-p.z
      local length=math.sqrt(dx*dx+dz*dz)
      if length>.01 then c.boss:set_velocity_vector({x=-dz/length*.22,y=.06,z=dx/length*.22}) end
      s.nextDodge=s.tick+160; s.nextStrike=s.tick+20
      c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.4,1.4)
      return
    end
    c.boss:face_direction_or_location(q)
    c.boss:set_ai_enabled(false,28)
    s.strike=ground_circle(c,q,1.4); s.strikeAt=s.tick+28
    c.boss:play_sound_at_self('BLOCK_WOODEN_BUTTON_CLICK_ON',.5,.8)
  end,
  on_boss_damaged_by_player=function(c)
    if c.state.breathUntil then
      c.state.breathUntil=nil; c.state.nextStrike=c.state.tick+50
      c.scheduler:run_later(50,function() c.boss:set_ai_enabled(true) end)
      c.players:current_target():send_message('&6Adventurer Instructor: &fExactly. Do not give me that opening.')
      c.boss:play_sound_at_self('BLOCK_WOODEN_BUTTON_CLICK_OFF',.5,1.3)
    end
  end,
  on_death=function(c)
    c.boss:send_message('&6Adventurer Instructor: &fA steady start. The road is yours now.',24)
  end
}


