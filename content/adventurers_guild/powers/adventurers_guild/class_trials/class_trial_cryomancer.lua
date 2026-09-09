-- @include ground_markers.inc
-- @include mobility/arcane_blink.inc

-- Three ice patches leave the rear quarter clear. Breaking the marked barrier
-- ends the storm early. Slowness is short and ordinary, with no private debuff owner.
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextWhiteout=50; s.nextBarrier=120
   player:send_message('&6Cryomancer Instructor: &fThe storm leaves a way around. The ice holding it together can break.')
  end
  if (s.wardUntil or 0)<=s.tick then s.ward=0 end
  if (s.ward or 0)>0 and s.tick%6==0 then c.boss:spawn_particle_at_self({particle='SNOWFLAKE',amount=8},1) end
  if (s.stormUntil or 0)>s.tick then
   if s.tick%5==0 then for _,zone in ipairs(s.patches) do show_circle(c,zone,110,205,245) end end
   if s.tick>=s.nextPulse then
    s.nextPulse=s.tick+25
    for _,zone in ipairs(s.patches) do
     if zone:contains(player:get_location()) then
      c.script:damage(zone:full_target(),1,.2); player:apply_potion_effect('SLOWNESS',16,0); break
     end
    end
   end
  end
  if s.stormAt then
   if s.tick%4==0 then for _,zone in ipairs(s.patches) do show_circle(c,zone,110,205,245) end end
   if s.tick>=s.stormAt then s.stormAt=nil; s.stormUntil=s.tick+100; s.nextPulse=s.tick; s.busyUntil=s.tick+12 end
   return
  end
  if s.barrierAt then
   if s.tick%4==0 then c.boss:spawn_particle_at_self({particle='SNOWFLAKE',amount=8},1) end
   if s.tick>=s.barrierAt then s.barrierAt=nil; s.ward=c.boss:get_maximum_health()*.06; s.wardUntil=s.tick+100; s.busyUntil=s.tick+140 end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; player:send_message('&6Cryomancer Instructor: &fA different clearing. Find the quiet side again.')
   if arcane_blink(c,player) then s.busyUntil=s.tick+46; return end
  end
  if s.tick>=s.nextWhiteout then
   s.nextWhiteout=s.tick+480; s.patches={}; local p,q=c.boss:get_location(),player:get_location()
   local dx,dz=q.x-p.x,q.z-p.z; local d=math.sqrt(dx*dx+dz*dz); if d<.01 then dx,dz,d=0,1,1 end
   for _,angle in ipairs({-90,0,90}) do
    local a=math.rad(angle); local x=(dx*math.cos(a)-dz*math.sin(a))/d; local z=(dx*math.sin(a)+dz*math.cos(a))/d
    s.patches[#s.patches+1]=ground_circle(c,{world=p.world,x=p.x+x*3,y=p.y,z=p.z+z*3},2)
   end
   s.stormAt=s.tick+36; pause_movement(c,48); c.boss:play_sound_at_self('BLOCK_GLASS_HIT',.6,.7)
  elseif s.tick>=s.nextBarrier then
   s.nextBarrier=s.tick+440; s.barrierAt=s.tick+32; pause_movement(c,172)
   c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_RESONATE',.6,1.4)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state; local amount=c.event.get_damage_amount()
  if (s.ward or 0)<=0 or amount<=0 then return end
  local used=math.min(amount,s.ward); s.ward=s.ward-used; c.event.multiply_damage_amount((amount-used)/amount)
  if s.ward<=0 then
   s.stormUntil=0; s.busyUntil=(s.tick or 0)+60; pause_movement(c,60)
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.6,1.2)
   c.boss:send_message('&6Cryomancer Instructor: &fThe barrier gives way. So does the storm.',24)
  end
 end,
 on_death=function(c) c.boss:send_message('&6Cryomancer Instructor: &fYou found stillness where others saw only snow.',24) end
}
