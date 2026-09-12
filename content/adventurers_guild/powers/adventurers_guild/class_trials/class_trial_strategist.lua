-- @include ground_markers.inc
-- @include mobility/steed_charge.inc

local function close(a,b)
 local p,q=a:get_location(),b:get_location()
 return math.abs(p.y-q.y)<3 and (p.x-q.x)^2+(p.z-q.z)^2<=25
end
local function intact(c)
 local s=c.state
 return s.archer:is_alive() and s.cadet:is_alive() and close(c.boss,s.archer)
  and close(c.boss,s.cadet) and close(s.archer,s.cadet)
end
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.archer=c.world:spawn_custom_boss_at_location('class_trial_ward_archer.yml',
   {world=p.world,x=p.x-2,y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  c.state.cadet=c.world:spawn_custom_boss_at_location('class_trial_guardian_apprentice.yml',
   {world=p.world,x=p.x+2,y=p.y,z=p.z+2},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.archer and c.state.cadet,'Strategist cadets could not spawn')
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextFormation=50; s.nextArrow=100
   player:send_message('&6Strategist Instructor: &fThree corners hold the formation. Move one.')
  end
  s.formationActive=(s.formationUntil or 0)>s.tick and intact(c)
  if (s.formationUntil or 0)>s.tick and not s.formationActive then
   s.formationUntil=0; s.exposedUntil=s.tick+60; s.busyUntil=s.tick+60; pause_movement(c,60)
   player:send_message('&6Strategist Instructor: &fOne corner moved. The advantage is yours.')
  end
  if s.formationActive and s.tick%5==0 then
   local points={c.boss:get_location(),s.archer:get_location(),s.cadet:get_location()}
   for i=1,3 do
    local a,b=points[i],points[i%3+1]
    for j=0,8 do c.world:spawn_particle_at_location({world=a.world,x=a.x+(b.x-a.x)*j/8,
     y=a.y+1,z=a.z+(b.z-a.z)*j/8},{particle='DUST',red=245,green=210,blue=110,amount=1},1) end
   end
  end
  if s.archer:is_alive() and s.tick>=s.nextArrow and s.tick>=(s.exposedUntil or 0) then
   s.nextArrow=s.tick+120
   local aim=player:get_eye_location()
   s.archer:face_direction_or_location(aim); s.archer:play_sound_at_self('BLOCK_NOTE_BLOCK_HARP',.5,1)
   c.scheduler:run_later(30,function()
    if s.archer:is_alive() then c.boss:summon_projectile('ARROW',s.archer:get_eye_location(),aim,.8,
     {gravity=false,spawn_at_origin=true,duration=60,persistent=false}) end
   end)
  end
  if s.formAt and s.tick>=s.formAt then s.formAt=nil; s.formationUntil=intact(c) and s.tick+120 or 0 end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.formationUntil=0; s.busyUntil=s.tick+65; steed_charge(c,player)
   player:send_message('&6Strategist Instructor: &fNew ground. The same lesson.')
  elseif s.tick>=s.nextFormation and s.archer:is_alive() and s.cadet:is_alive() then
   local p=c.boss:get_location(); s.nextFormation=s.tick+420; s.formAt=s.tick+60; s.busyUntil=s.tick+90
   s.cadet:navigate_to_location({world=p.world,x=p.x+2,y=p.y,z=p.z+2},.8,false,60)
   s.archer:navigate_to_location({world=p.world,x=p.x-2,y=p.y,z=p.z+2},.8,false,60)
   pause_movement(c,90); c.boss:play_sound_at_self('ITEM_GOAT_HORN_SOUND_0',.5,1.2)
  end
 end,
 on_boss_damaged_by_player=function(c)
  if c.event.is_damage_transfer then return end
  if c.state.formationActive and intact(c) then c.event.multiply_damage_amount(.7) end
  if (c.state.exposedUntil or 0)>(c.state.tick or 0) then c.event.multiply_damage_amount(1.2) end
 end,
 on_player_damaged_by_boss=function(c)
  if c.event.projectile then c.event.multiply_damage_amount(.25) end
  if c.state.formationActive and intact(c) then c.event.multiply_damage_amount(1.15) end
 end,
 on_death=function(c) c.boss:send_message('&6Strategist Instructor: &fA formation is only as strong as its weakest corner. You found ours.',24) end
}
