-- @include mobility/windstep.inc

-- Marked shots lock their aim before release. The second phase alternates two
-- offset fans. Arrows retain normal terrain/entity collision and boss scaling.
local function point(p,x,y,z)
  return {x=p.x+x,y=p.y+y,z=p.z+z,world=p.world}
end
local function lanes(c,target,angles,fire)
  local origin=c.boss:get_eye_location()
  local x,z=target.x-origin.x,target.z-origin.z
  local length=math.sqrt(x*x+z*z)
  if length<.01 then return end
  x,z=x/length,z/length
  for _,degrees in ipairs(angles) do
    local a=math.rad(degrees)
    local dx,dz=x*math.cos(a)-z*math.sin(a),x*math.sin(a)+z*math.cos(a)
    if fire then
      c.boss:summon_projectile('ARROW',origin,point(origin,dx*length,target.y-origin.y,dz*length),.9,
        {gravity=false,persistent=false,spawn_at_origin=true,duration=60})
    else
      for distance=1,18 do
        c.world:spawn_particle_at_location(point(origin,dx*distance,-1.35,dz*distance),
          {particle='DUST',red=240,green=185,blue=70,amount=1},1)
      end
    end
  end
  if fire then c.boss:play_sound_at_self('ENTITY_ARROW_SHOOT',.7,1) end
end
return {
  api_version=1,
  on_game_tick=function(c)
    local player=c.boss:get_target_player()
    if not player or not player:is_alive() then return end
    local s=c.state
    s.tick=(s.tick or 0)+1
    if not s.started then
      s.started=true; s.nextShot=s.tick+60; s.nextStep=0; s.shots=0
      player:send_message('&6Ranger Instructor: &fWatch the bow. Move when I commit, not when I look at you.')
    end
    if not s.secondPhase and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
      s.secondPhase=true
      player:send_message("&6Ranger Instructor: &fYou've found the gap. Now watch the second lane.")
    end
    if s.lockAt and s.tick<s.lockAt then
      s.aim=player:get_eye_location()
      c.boss:face_direction_or_location(s.aim)
    end
    if s.fireAt then
      if s.tick%4==0 then lanes(c,s.aim,s.angles,false) end
      if s.tick>=s.fireAt then
        lanes(c,s.aim,s.angles,true)
        if s.secondPhase and not s.followup then
          s.followup=true; s.angles={-10,6,18}; s.fireAt=s.tick+24
        else
          s.fireAt=nil; s.lockAt=nil; s.followup=nil; s.nextShot=s.tick+65
        end
      end
      return
    end
    local p,q=c.boss:get_location(),player:get_location()
    local distance=math.sqrt((p.x-q.x)^2+(p.z-q.z)^2)
    if distance<6 and s.tick>=s.nextStep then
      windstep(c,player,s.tick)
      s.nextStep=s.tick+220; s.nextShot=math.max(s.nextShot,s.tick+25)
    end
    if s.tick<s.nextShot then return end
    s.shots=s.shots+1; s.marked=s.shots%3==0
    s.aim=player:get_eye_location(); s.lockAt=s.tick+16; s.fireAt=s.tick+32
    s.angles=s.secondPhase and {-18,-6,10} or {-12,0,12}
    c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_HARP',.65,.8)
    if s.marked then
      player:send_message("&6Ranger Instructor: &fHunter's Mark. Wait for the lane to settle, then move.")
      s.fireAt=s.tick+44; s.lockAt=s.tick+24
    end
  end,
  on_player_damaged_by_boss=function(c)
    if c.event.projectile then
      -- The normal damage event has already applied normalized boss scaling.
      c.event.multiply_damage_amount(c.state.marked and .54 or .45)
    end
  end,
  on_death=function(c)
    c.boss:send_message('&6Ranger Instructor: &fYou read the shot before it left the string. Welcome to the trail.',24)
  end
}

