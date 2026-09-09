-- Shared Paladin Judgment. The boss listens for normal incoming damage while the
-- scales are visible, then commits one marked cleave. Callers own recurrence.
local function judgment(c,cap)
  local s=c.state
  s.judgmentWeights=0; s.judgmentCollecting=true; s.busyUntil=s.tick+120
  c.boss:set_ai_enabled(false,120)
  c.boss:play_sound_at_self('BLOCK_ANVIL_PLACE',.55,.6)
  c.scheduler:run_later(60,function()
    s.judgmentCollecting=false
    local player=c.boss:get_target_player()
    if not player or not player:is_alive() then return end
    local zone=forward_cone(c,c.boss:get_location(),player:get_location(),3.5,1.8)
    c.boss:face_direction_or_location(player:get_location())
    local tell,task=0,nil
    task=c.scheduler:run_repeating(0,4,function()
      show_circle(c,zone,245,215,110); tell=tell+4
      if tell>=28 then c.scheduler:cancel(task) end
    end)
    c.scheduler:run_later(30,function()
      c.script:damage(zone:full_target(),1,math.min(cap,.6+.2*s.judgmentWeights))
      c.boss:play_sound_at_self('ENTITY_PLAYER_ATTACK_CRIT',.6,.8)
    end)
  end)
end
local function weigh_judgment(c)
  if c.state.judgmentCollecting and not c.event.is_damage_transfer then
    c.state.judgmentWeights=math.min(3,c.state.judgmentWeights+1)
    c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_BELL',.4,.7+.2*c.state.judgmentWeights)
  end
end
local function show_judgment(c)
  if not c.state.judgmentCollecting then return end
  local p=c.boss:get_location()
  for i=1,c.state.judgmentWeights do
    c.world:spawn_particle_at_location({x=p.x+(i-2)*.65,y=p.y+2,z=p.z,world=p.world},
      {particle='DUST',red=245,green=215,blue=110,amount=1},1)
  end
end
