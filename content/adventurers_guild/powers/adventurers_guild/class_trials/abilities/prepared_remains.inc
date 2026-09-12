-- Soul Drain and Death Coil consume ordinary destructible remains. Each corpse
-- can raise one normal undead, whose lifetime uses the existing owned scheduler.
local function prepared_remains(c,count)
 local p=c.boss:get_location(); local corpses={}
 for i=1,count do
  local actor=c.world:spawn_custom_boss_at_location('class_trial_prepared_remains.yml',
   {world=p.world,x=p.x+(i-(count+1)/2)*3,y=p.y,z=p.z+4},
   {level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(actor,'Prepared remains could not spawn'); corpses[i]=actor
 end
 return corpses
end
local function next_remains(c)
 for _,actor in ipairs(c.state.corpses) do if actor:is_alive() then return actor end end
end
local function raise_undead(c,corpse)
 if not corpse or not corpse:is_alive() then return nil end
 local p=corpse:get_location(); corpse:remove_elite()
 local actor=c.world:spawn_custom_boss_at_location('class_trial_raised_undead.yml',p,
  {level=c.boss.level,add_as_reinforcement=true,silent=true})
 assert(actor,'Raised undead could not spawn')
 c.scheduler:run_later(200,function() if actor:is_alive() then actor:remove_elite() end end)
 return actor
end
