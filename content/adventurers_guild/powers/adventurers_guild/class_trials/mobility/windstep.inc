-- Shared Ranger mobility uses ordinary velocity and terrain collision.
local function windstep(c,player,tick)
  local p,q=c.boss:get_location(),player:get_location()
  local dx,dz=q.x-p.x,q.z-p.z
  local length=math.sqrt(dx*dx+dz*dz)
  if length<.01 then return end
  local side=(math.floor(tick/220)%2==0) and 1 or -1
  c.boss:set_velocity_vector({x=-dz/length*.38*side,y=.08,z=dx/length*.38*side})
  c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.5,1.5)
  c.world:spawn_particle_at_location(p,{particle='DUST',red=95,green=190,blue=110,amount=12},1)
end
