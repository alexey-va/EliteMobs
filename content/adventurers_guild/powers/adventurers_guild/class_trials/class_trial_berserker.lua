-- @include ground_markers.inc
-- @include mobility/leap_slam.inc

-- Rampage commits each of three swings separately. Dodge each tell; the long
-- recovery is the opening. War Cry briefly slows its outer ring, not the center.
return {
  api_version=1,
  on_game_tick=function(c)
    local player=c.boss:get_target_player()
    if not player or not player:is_alive() then return end
    local s=c.state; s.tick=(s.tick or 0)+1
    if not s.started then
      s.started=true; s.nextRampage=70; s.nextCry=180; s.nextLeap=120
      player:send_message('&6Berserker Instructor: &fThree swings. Keep your nerve until the last one.')
    end
    if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
      s.phaseTwo=true
      player:send_message('&6Berserker Instructor: &fStill standing? Good. Watch where I land.')
      s.nextLeap=s.tick
    end
    if s.swingAt then
      if s.tick%4==0 then show_circle(c,s.swing,240,125,60) end
      if s.tick>=s.swingAt then
        c.script:damage(s.swing:full_target(),1,.45)
        c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.6,.8)
        s.swings=s.swings+1
        if s.swings<3 then
          s.swing=forward_cone(c,c.boss:get_location(),player:get_location(),3.5,1.8)
          s.swingAt=s.tick+24
          c.boss:face_direction_or_location(player:get_location())
        else s.swingAt=nil; s.recoveryUntil=s.tick+50; s.nextRampage=s.tick+280 end
      end
      return
    end
    if s.cryAt then
      if s.tick%4==0 then show_circle(c,s.cry,225,155,60) end
      if s.tick>=s.cryAt then
        for _,target in ipairs(s.cry:border_target():entities()) do target:apply_potion_effect('SLOWNESS',20,0) end
        s.cryAt=nil; s.recoveryUntil=s.tick+30
      end
      return
    end
    if s.tick<(s.recoveryUntil or 0) then return end
    local p,q=c.boss:get_location(),player:get_location()
    if s.tick>=s.nextLeap and (p.x-q.x)^2+(p.z-q.z)^2>16 then
      if leap_slam(c,player) then s.recoveryUntil=s.tick+100 end
      s.nextLeap=s.tick+360
    elseif s.tick>=s.nextRampage then
      s.swings=0; s.swingAt=s.tick+30
      s.swing=forward_cone(c,p,q,3.5,1.8)
      c.boss:face_direction_or_location(q); c.boss:set_ai_enabled(false,128)
      c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_BASEDRUM',.6,.6)
    elseif s.tick>=s.nextCry then
      s.cry=ground_circle(c,p,4); s.cryAt=s.tick+24; s.nextCry=s.tick+280
      c.boss:set_ai_enabled(false,54); c.boss:play_sound_at_self('ENTITY_RAVAGER_ROAR',.6,1.4)
    end
  end,
  on_boss_damaged_by_player=function(c)
    if (c.state.recoveryUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
  end,
  on_death=function(c)
    c.boss:send_message('&6Berserker Instructor: &fYou held your ground without standing still. That will do.',24)
  end
}
