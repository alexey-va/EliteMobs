-- Ordinary script zones provide targeting and geometry. These helpers only keep
-- the ground-marker presentation consistent across authored abilities.
local function ground_circle(c,p,radius)
  return c.script:zone({shape='CYLINDER',radius=radius,height=2,filter='PLAYER',ignoresSolidBlocks=false,
    target={targetType='LOCATION',location='same_as_boss,'..p.x..','..p.y..','..p.z}})
end
local function show_circle(c,zone,red,green,blue)
  c.script:spawn_particles(zone:border_target(.5),{particle='DUST',red=red,green=green,blue=blue,amount=1})
end
local function forward_cone(c,origin,target,length,width)
  local dx,dz=target.x-origin.x,target.z-origin.z
  local distance=math.sqrt(dx*dx+dz*dz)
  if distance<.01 then dx,dz,distance=0,1,1 end
  local finish={x=origin.x+dx/distance*length,y=origin.y+.75,z=origin.z+dz/distance*length}
  return c.script:zone({shape='CONE',radius=width,filter='PLAYER',
    target={targetType='LOCATION',location='same_as_boss,'..origin.x..','..(origin.y+.75)..','..origin.z},
    target2={targetType='LOCATION',location='same_as_boss,'..finish.x..','..finish.y..','..finish.z}})
end

-- A power owns one movement pause. Replacing it cancels its earlier restoration,
-- so an interrupted channel cannot unfreeze the next ability prematurely.
local function pause_movement(c,ticks)
  if c.state.movementRestore then c.scheduler:cancel(c.state.movementRestore) end
  c.boss:set_ai_enabled(false)
  c.state.movementRestore=c.scheduler:run_later(ticks,function()
    c.state.movementRestore=nil
    if c.boss:is_alive() then c.boss:set_ai_enabled(true) end
  end)
end
