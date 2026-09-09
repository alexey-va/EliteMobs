-- A shared three-swing sword drill. Each swing locks independently, and callers
-- choose its reach, cadence and strength. Uses ordinary scheduler and cone zones.
local function three_swing_drill(c,player,timings,damage)
 local s=c.state; s.busyUntil=s.tick+timings[1]+timings[2]+timings[3]+68
 pause_movement(c,timings[1]+timings[2]+timings[3]+68)
 local elapsed=0
 for i=1,3 do
  local swing=i
  c.scheduler:run_later(elapsed,function()
   local current=c.boss:get_target_player(); if not current or not current:is_alive() then return end
   local zone=forward_cone(c,c.boss:get_location(),current:get_location(),swing==3 and 4 or 3.5,swing==3 and 1.2 or 2.1)
   c.boss:face_direction_or_location(current:get_location())
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_BASEDRUM',.55,swing==3 and .5 or 1)
   local age,task=0,nil
   task=c.scheduler:run_repeating(0,4,function()
    show_circle(c,zone,235,180,85); age=age+4
    if age>=timings[swing] then c.scheduler:cancel(task) end
   end)
   c.scheduler:run_later(timings[swing],function()
    c.script:damage(zone:full_target(),1,damage[swing])
    c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_SWEEP',.55,swing==3 and .6 or 1.1)
    if swing==3 then s.exposedUntil=s.tick+60 end
   end)
  end)
  elapsed=elapsed+timings[i]+4
 end
end
