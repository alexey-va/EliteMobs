-- A committed lateral run. Ordinary velocity preserves ground and walls;
-- there is no forced arrival, teleport, collision bypass or movement manager.
local function strafe(c,player,duration)
 local p,q=c.boss:get_location(),player:get_location()
 local dx,dz=q.x-p.x,q.z-p.z; local d=math.sqrt(dx*dx+dz*dz)
 if d<.01 then return end
 local side=c.state.phaseTwo and -1 or 1
 local vx,vz=-dz/d*.16*side,dx/d*.16*side
 local age,task=0,nil
 task=c.scheduler:run_repeating(0,1,function()
  if not c.boss:is_alive() then c.scheduler:cancel(task); return end
  local v=c.boss:get_velocity(); c.boss:set_velocity_vector({x=vx,y=v.y,z=vz})
  age=age+1
  if age%6==0 then c.boss:spawn_particle_at_self({particle='DUST',red=140,green=215,blue=180,amount=2},1) end
  if age>=duration then c.scheduler:cancel(task) end
 end)
 c.boss:play_sound_at_self('ENTITY_BREEZE_SLIDE',.5,1.2)
end
