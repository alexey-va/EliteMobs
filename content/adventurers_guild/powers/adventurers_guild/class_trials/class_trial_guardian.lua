-- @include mobility/steed_charge.inc

-- The apprentice is an ordinary custom boss. Intercession transfers part of its
-- damage through the normal reinforcement hook; separating the pair breaks it.
local function distance(a,b)
  return math.sqrt((a.x-b.x)^2+(a.z-b.z)^2)
end
local function tether(c,a,b)
  for i=0,12 do
    local f=i/12
    c.world:spawn_particle_at_location({x=a.x+(b.x-a.x)*f,y=a.y+1,z=a.z+(b.z-a.z)*f,world=a.world},
      {particle='DUST',red=245,green=220,blue=125,amount=1},1)
  end
end
return {
  api_version=1,
  on_spawn=function(c)
    local p=c.boss:get_location()
    c.state.apprentice=c.world:spawn_custom_boss_at_location('class_trial_guardian_apprentice.yml',
      {x=p.x+3,y=p.y,z=p.z+2,world=p.world},{level=c.boss.level,add_as_reinforcement=true,silent=true})
    assert(c.state.apprentice,'Guardian apprentice could not spawn')
  end,
  on_game_tick=function(c)
    local player=c.boss:get_target_player()
    if not player or not player:is_alive() then return end
    local s=c.state; s.tick=(s.tick or 0)+1
    if not s.started then
      s.started=true; s.nextLink=s.tick+60; s.linkUntil=0; s.nextCharge=s.tick+180
      player:send_message('&6Guardian Instructor: &fThe space between a blade and an ally belongs to you. Watch the tether.')
    end
    if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
      s.phaseTwo=true
      player:send_message('&6Guardian Instructor: &fYou found my charge. Can you draw us apart?')
      steed_charge(c,player); s.nextCharge=s.tick+300
    elseif s.tick>=s.nextCharge and distance(c.boss:get_location(),player:get_location())>7 then
      steed_charge(c,player); s.nextCharge=s.tick+300
    end
    if not s.apprentice or not s.apprentice:is_alive() then return end
    local p,q=c.boss:get_location(),s.apprentice:get_location()
    if s.tick>=s.nextLink then
      s.nextLink=s.tick+240; s.warnUntil=s.tick+30
      c.boss:play_sound_at_self('BLOCK_BELL_USE',.6,1)
    end
    if s.warnUntil and s.tick>=s.warnUntil then
      s.warnUntil=nil; s.linkUntil=s.tick+100
    end
    if (s.warnUntil or s.linkUntil>s.tick) and distance(p,q)<=8 and s.tick%5==0 then tether(c,p,q) end
    if s.linkUntil>s.tick and distance(p,q)>8 then
      s.linkUntil=0
      player:send_message('&6Guardian Instructor: &fThere. Even a guardian cannot stand everywhere.')
    end
  end,
  on_reinforcement_damaged_by_player=function(c)
    local s=c.state
    if c.event.is_damage_transfer or not s.apprentice or not s.apprentice:is_alive()
      or c.event.entity.uuid~=s.apprentice.uuid or (s.linkUntil or 0)<=(s.tick or 0)
      or distance(c.boss:get_location(),s.apprentice:get_location())>8 then return end
    local amount=c.event.get_damage_amount()*.6
    if c.event:transfer_damage(c.boss,amount) then c.event.multiply_damage_amount(.4) end
  end,
  on_death=function(c)
    c.boss:send_message('&6Guardian Instructor: &fYou understood whom I was protecting, and why.',24)
  end
}
