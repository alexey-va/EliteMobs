-- The Reaver and Slayer branches share the same visible hunting mark.
local function blood_scent(c,duration)
 local s=c.state; s.busyUntil=s.tick+50; pause_movement(c,50)
 c.boss:play_sound_at_self('ENTITY_WOLF_GROWL',.6,.8)
 c.scheduler:run_later(26,function()
  s.markUntil=s.tick+duration
  c.boss:apply_potion_effect('SPEED',duration,0)
 end)
end
local function show_blood_scent(c,player)
 if (c.state.markUntil or 0)>(c.state.tick or 0) and c.state.tick%10==0 then
  player:spawn_particle_at_self({particle='DUST',red=190,green=45,blue=45,amount=2},1)
 end
end
