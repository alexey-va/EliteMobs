-- Normal snowball projectiles use EliteMobs' projectile attribution and damage
-- hooks. These functions only draw the aim and release the native projectile.
local function spell_aim(c,target)
 local p=c.boss:get_eye_location()
 for i=0,12 do
  local t=i/12
  c.world:spawn_particle_at_location({world=p.world,x=p.x+(target.x-p.x)*t,y=p.y+(target.y-p.y)*t,z=p.z+(target.z-p.z)*t},
   {particle='DUST',red=170,green=120,blue=245,amount=1},1)
 end
end
local function spell_bolt(c,target,speed)
 c.boss:summon_projectile('SNOWBALL',c.boss:get_eye_location(),target,speed or .8,
  {gravity=false,persistent=false,spawn_at_origin=true,duration=60})
 c.boss:play_sound_at_self('ENTITY_BLAZE_SHOOT',.5,1.6)
end
