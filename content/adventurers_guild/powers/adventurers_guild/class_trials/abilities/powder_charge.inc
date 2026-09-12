-- A visible, destructible delayed blast shared by the explosives branch.
local function powder_charge(c,position,fuse,strength)
 local actor=c.world:spawn_custom_boss_at_location('class_trial_powder_charge.yml',position,
  {level=c.boss.level,add_as_reinforcement=true,silent=true})
 assert(actor,'Powder charge could not spawn')
 local zone=ground_circle(c,position,1.6)
 local age,task=0,nil
 actor:play_sound_at_self('ENTITY_TNT_PRIMED',.5,1.2)
 task=c.scheduler:run_repeating(0,4,function()
  if not actor:is_alive() then c.scheduler:cancel(task); return end
  age=age+4; show_circle(c,zone,240,150,70)
  if age>=fuse then
   actor:play_sound_at_self('ENTITY_GENERIC_EXPLODE',.6,1.2)
   c.script:damage(zone:full_target(),1,strength); actor:remove_elite(); c.scheduler:cancel(task)
  elseif age%12==0 then actor:play_sound_at_self('BLOCK_NOTE_BLOCK_HAT',.4,.8+age/fuse) end
 end)
 return actor
end
