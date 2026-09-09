-- Blink uses one nearby, full-air destination on the same floor. The existing
-- world raycast rejects walls and intervening entities before and after its tell.
local function blink_open(c,p,q)
 if not c.world:is_on_floor_at_location(q) or not c.world:is_air_at_location(q)
   or not c.world:is_air_at_location({world=q.world,x=q.x,y=q.y+1,z=q.z}) then return false end
 local dx,dz=p.x-q.x,p.z-q.z; local distance=math.sqrt(dx*dx+dz*dz)
 if distance<2 or distance>6 then return false end
 local ray=c.world:raycast(q.x,q.y+1,q.z,dx,0,dz,distance)
 local self=c.script:target({targetType='SELF'}):entities()[1]
 return not ray.hit_block and (not ray.hit_entity or (self and ray.hit_entity.uuid==self.uuid))
end
local function arcane_blink(c,player)
 local p,q=c.boss:get_location(),player:get_location(); local dx,dz=q.x-p.x,q.z-p.z
 local distance=math.sqrt(dx*dx+dz*dz); if distance<.01 then return false end
 local side=c.state.blinkSide or 1; c.state.blinkSide=-side; local destination
 for _,sign in ipairs({side,-side}) do
  local candidate={world=p.world,x=math.floor(p.x-dz/distance*4*sign)+.5,y=p.y,z=math.floor(p.z+dx/distance*4*sign)+.5}
  if blink_open(c,p,candidate) then destination=candidate; break end
 end
 if not destination then return false end
 local marker=ground_circle(c,destination,.65); pause_movement(c,46)
 c.boss:play_sound_at_self('BLOCK_AMETHYST_BLOCK_CHIME',.6,.8)
 for delay=0,16,4 do c.scheduler:run_later(delay,function() show_circle(c,marker,160,120,255) end) end
 c.scheduler:run_later(20,function()
  if c.boss:is_alive() and blink_open(c,c.boss:get_location(),destination) then
   c.boss:teleport_to_location(destination); c.boss:play_sound_at_self('ENTITY_ENDERMAN_TELEPORT',.6,1.3)
  else c.boss:play_sound_at_self('BLOCK_FIRE_EXTINGUISH',.5,1.2) end
 end)
 return true
end
