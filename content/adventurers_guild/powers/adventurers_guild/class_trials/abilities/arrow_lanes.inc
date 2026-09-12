-- Aiming lines and normal arrows share the same direction, including elevation.
-- This helper has no damage receipts, hit budgets or encounter lifecycle.
local function arrow_lanes(c,target,angles,speed,fire)
 local origin=c.boss:get_eye_location()
 local x,z=target.x-origin.x,target.z-origin.z
 local distance=math.sqrt(x*x+z*z); if distance<.01 then return end
 x,z=x/distance,z/distance
 for _,degrees in ipairs(angles) do
  local a=math.rad(degrees)
  local dx,dz=x*math.cos(a)-z*math.sin(a),x*math.sin(a)+z*math.cos(a)
  if fire then
   c.boss:summon_projectile('ARROW',origin,{world=origin.world,x=origin.x+dx*distance,
    y=target.y,z=origin.z+dz*distance},speed,
    {gravity=false,persistent=false,spawn_at_origin=true,duration=60})
  else
   for step=1,18 do c.world:spawn_particle_at_location({world=origin.world,
    x=origin.x+dx*step,y=origin.y-1.35,z=origin.z+dz*step},
    {particle='DUST',red=240,green=185,blue=70,amount=1},1) end
  end
 end
 if fire then c.boss:play_sound_at_self('ENTITY_ARROW_SHOOT',.6,1) end
end
