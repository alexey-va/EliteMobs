-- Bounded healing and its presentation. Each ordinary power owns its decisions.
local function cleric_tether(c,first,second,blue)
 local a,b=first:get_location(),second:get_location()
 for i=0,10 do
  local t=i/10
  c.world:spawn_particle_at_location({world=a.world,x=a.x+(b.x-a.x)*t,
   y=a.y+1+(b.y-a.y)*t,z=a.z+(b.z-a.z)*t},
   {particle='DUST',red=blue and 85 or 245,green=220,blue=blue and 245 or 150,amount=1},1)
 end
end
local function cleric_heal(c,actor,fraction)
 if not actor or not actor:is_alive() then return end
 local maximum=actor:get_maximum_health()
 local amount=math.min(maximum*fraction,maximum-actor:get_health(),c.state.healingLeft or 0)
 if amount<=0 then return end
 actor:restore_health(amount)
 c.state.healingLeft=c.state.healingLeft-amount
 actor:spawn_particle_at_self({particle='HAPPY_VILLAGER',amount=4},1)
end
local function cleric_in_circle(actor,position,radius)
 if not actor or not actor:is_alive() then return false end
 local p=actor:get_location()
 return math.abs(p.y-position.y)<3 and (p.x-position.x)^2+(p.z-position.z)^2<=radius*radius
end
