-- @include ground_markers.inc
-- @include mobility/steed_charge.inc

local function separation(a,b) return math.sqrt((a.x-b.x)^2+(a.z-b.z)^2) end
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.archer=c.world:spawn_custom_boss_at_location('class_trial_ward_archer.yml',
   {x=p.x+3,y=p.y,z=p.z+2,world=p.world},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.archer,'Aegis archer could not spawn')
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextLink=60; s.nextSanctuary=200; s.nextArrow=100
   player:send_message('&6Aegis Instructor: &fThe archer stands beneath my protection. Find where it ends.')
  end
  if s.archer and s.archer:is_alive() then
   local p,q=c.boss:get_location(),s.archer:get_location()
   if s.linkUntil and s.linkUntil>s.tick then
    if separation(p,q)>7 then
     s.linkUntil=0; s.exposedUntil=s.tick+50
     player:send_message('&6Aegis Instructor: &fToo far apart. You found the edge of my protection.')
    elseif s.tick%5==0 then
     for i=0,10 do
      c.world:spawn_particle_at_location({x=p.x+(q.x-p.x)*i/10,y=p.y+1,z=p.z+(q.z-p.z)*i/10,world=p.world},
       {particle='DUST',red=245,green=220,blue=140,amount=1},1)
     end
    end
   end
   if s.tick>=s.nextArrow then
    s.nextArrow=s.tick+100
    local aim=player:get_eye_location()
    s.archer:face_direction_or_location(aim); s.archer:play_sound_at_self('BLOCK_NOTE_BLOCK_HARP',.5,.9)
    c.scheduler:run_later(28,function()
     if not s.archer or not s.archer:is_alive() then return end
     c.boss:summon_projectile('ARROW',s.archer:get_eye_location(),aim,.8,
      {gravity=false,spawn_at_origin=true,duration=60,persistent=false})
     s.archer:play_sound_at_self('ENTITY_ARROW_SHOOT',.5,1)
    end)
   end
  end
  if s.sanctuaryUntil and s.sanctuaryUntil>s.tick and s.tick%5==0 then show_circle(c,s.sanctuary,210,225,245) end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.busyUntil=s.tick+65
   player:send_message('&6Aegis Instructor: &fProtection has a place. Draw us away from it.')
   steed_charge(c,player)
  elseif s.tick>=s.nextLink and s.archer and s.archer:is_alive() then
   s.nextLink=s.tick+360; s.busyUntil=s.tick+30
   c.boss:play_sound_at_self('ITEM_SHIELD_BLOCK',.5,1.2)
   c.scheduler:run_later(30,function() s.linkUntil=s.tick+120 end)
  elseif s.tick>=s.nextSanctuary then
   s.nextSanctuary=s.tick+440; s.busyUntil=s.tick+32
   s.sanctuary=ground_circle(c,c.boss:get_location(),3)
   show_circle(c,s.sanctuary,210,225,245)
   c.scheduler:run_later(32,function() s.sanctuaryUntil=s.tick+100 end)
  end
 end,
 on_boss_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer then return end
  if (s.exposedUntil or 0)>(s.tick or 0) then c.event.multiply_damage_amount(1.2) end
  if c.event.damage_cause=='PROJECTILE' and (s.sanctuaryUntil or 0)>(s.tick or 0)
   and s.sanctuary:contains(c.boss:get_location()) then c.event.multiply_damage_amount(.35) end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if c.event.is_damage_transfer or not s.archer or c.event.entity.uuid~=s.archer.uuid then return end
  if c.event.damage_cause=='PROJECTILE' and (s.sanctuaryUntil or 0)>(s.tick or 0)
   and s.sanctuary:contains(s.archer:get_location()) then c.event.multiply_damage_amount(.35) end
  if (s.linkUntil or 0)>(s.tick or 0) and separation(c.boss:get_location(),s.archer:get_location())<=7 then
   if c.event:transfer_damage(c.boss,c.event.get_damage_amount()*.7) then c.event.multiply_damage_amount(.3) end
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.25) end end,
 on_death=function(c) c.boss:send_message('&6Aegis Instructor: &fYou learned the reach of a promise. Keep yours within it.',24) end
}
