-- The mace impact shared by Earthshatter and Sunderquake. Its ground is fixed
-- before the warning begins, with a short lift rather than a movement lock.
local function earthshatter(c,radius,strength)
 local s=c.state; local zone=ground_circle(c,c.boss:get_location(),radius)
 s.busyUntil=s.tick+96; pause_movement(c,96)
 c.boss:play_sound_at_self('BLOCK_GRAVEL_BREAK',.6,.7)
 local age,task=0,nil
 task=c.scheduler:run_repeating(0,4,function()
  show_circle(c,zone,185,150,110); age=age+4
  if age>=36 then c.scheduler:cancel(task) end
 end)
 c.scheduler:run_later(36,function()
  c.script:damage(zone:full_target(),1,strength)
  for _,player in ipairs(zone:full_target():entities()) do
   local v=player:get_velocity(); player:set_velocity_vector({x=v.x,y=.22,z=v.z})
   player:apply_potion_effect('WEAKNESS',30,0)
  end
  c.boss:play_sound_at_self('ENTITY_GENERIC_EXPLODE',.6,.7)
  s.exposedUntil=s.tick+60
 end)
end
