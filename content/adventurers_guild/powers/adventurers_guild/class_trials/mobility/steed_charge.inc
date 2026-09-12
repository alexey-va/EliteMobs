-- Shared Paladin mobility: a normal summoned steed, a committed direction and a
-- short charge. Terrain uses native collision. The ordinary parent owns the steed.
local function steed_charge(c,player)
  local origin=c.boss:get_location()
  local target=player:get_location()
  local dx,dz=target.x-origin.x,target.z-origin.z
  local distance=math.sqrt(dx*dx+dz*dz)
  if distance<.1 then return end
  local steed=c.world:spawn_custom_boss_at_location('class_trial_steed.yml',origin,
    {level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(steed,'Summoned steed could not spawn')
  if not c.boss:set_mount(steed) then steed:remove_elite(); return end
  c.boss:play_sound_at_self('ENTITY_HORSE_AMBIENT',.6,.9)
  local elapsed,task=0,nil
  task=c.scheduler:run_repeating(24,1,function()
    if not steed:is_alive() or not c.boss:is_alive() then c.scheduler:cancel(task); return end
    elapsed=elapsed+1
    steed:set_velocity_vector({x=dx/distance*.5,y=steed:get_velocity().y,z=dz/distance*.5})
    if elapsed>=16 then
      steed:set_velocity_vector({x=0,y=0,z=0})
      c.boss:dismount(); steed:remove_elite(); c.scheduler:cancel(task)
    end
  end)
end
