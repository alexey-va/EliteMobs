-- Guardian Flight commits to a nearby healing anchor. Native velocity and
-- gravity preserve walls and terrain; it never teleports to force arrival.
local function radiant_flight(c,anchor)
 if not anchor then return false end
 local p=c.boss:get_location()
 local dx,dz=anchor.x-p.x,anchor.z-p.z
 local distance=math.sqrt(dx*dx+dz*dz)
 if distance<2 or distance>9 then return false end
 local zone=ground_circle(c,anchor,1.2)
 local age,task=0,nil
 c.boss:set_ai_enabled(false,60)
 c.boss:play_sound_at_self('ENTITY_ALLAY_AMBIENT_WITHOUT_ITEM',.6,1.2)
 task=c.scheduler:run_repeating(0,1,function()
  if not c.boss:is_alive() then c.scheduler:cancel(task); return end
  age=age+1
  if age<=20 and age%4==0 then show_circle(c,zone,245,230,160) end
  if age==20 then c.boss:set_velocity_vector({x=dx/distance*.48,y=.48,z=dz/distance*.48}) end
  if (age>26 and c.boss:is_on_ground()) or age>=60 then c.scheduler:cancel(task) end
 end)
 return true
end
