-- Shared Berserker leap. Native velocity handles terrain; a missed landing does
-- not deal damage at the old target position.
local function leap_slam(c,player)
  local origin,target=c.boss:get_location(),player:get_location()
  local dx,dz=target.x-origin.x,target.z-origin.z
  local length=math.sqrt(dx*dx+dz*dz)
  if length<.1 or length>8 then return false end
  local zone=ground_circle(c,target,3)
  local age,task=0,nil
  pause_movement(c,60)
  c.boss:play_sound_at_self('BLOCK_GRAVEL_BREAK',.6,.7)
  task=c.scheduler:run_repeating(0,1,function()
    age=age+1
    if age<=30 and age%4==0 then show_circle(c,zone,210,130,65) end
    if age==30 then c.boss:set_velocity_vector({x=dx/length*.42,y=.58,z=dz/length*.42}) end
    if age>36 and c.boss:is_on_ground() then
      local p=c.boss:get_location()
      if (p.x-target.x)^2+(p.z-target.z)^2<=4 then
        c.script:damage(zone:full_target(),1,.8)
        c.boss:play_sound_at_self('ENTITY_GENERIC_EXPLODE',.45,.7)
      else c.boss:play_sound_at_self('BLOCK_STONE_HIT',.4,.7) end
      c.scheduler:cancel(task)
    elseif age>=60 then c.scheduler:cancel(task) end
  end)
  return true
end
