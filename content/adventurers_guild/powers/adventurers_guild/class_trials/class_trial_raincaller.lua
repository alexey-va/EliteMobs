-- @include ground_markers.inc
-- @include mobility/windstep.inc

local function storm_cells(c,s)
 s.cells={}; s.safeCells={}
 local safe=s.wave==1 and 2 or (s.phaseTwo and 3 or 1)
 for lane=1,3 do for _,along in ipairs({-2,2}) do
  local point={world=s.center.world,x=s.center.x+(lane-2)*3,y=s.center.y,z=s.center.z+along}
  local cell={point=point,zone=ground_circle(c,point,1.2)}
  table.insert(lane==safe and s.safeCells or s.cells,cell)
 end end
end
return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextStorm=70
   player:send_message('&6Raincaller Instructor: &fThe green lane stays dry. Watch it move before the second rain.')
  end
  if s.rainAt then
   if s.tick%4==0 then
    for _,cell in ipairs(s.cells) do show_circle(c,cell.zone,235,170,75) end
    for _,cell in ipairs(s.safeCells) do show_circle(c,cell.zone,130,220,180) end
   end
   if s.tick>=s.rainAt then
    for _,cell in ipairs(s.cells) do
     local q=cell.point
     for _,dx in ipairs({-.55,.55}) do
      c.boss:summon_projectile('ARROW',{world=q.world,x=q.x+dx,y=q.y+7,z=q.z},
       {world=q.world,x=q.x+dx,y=q.y,z=q.z},.9,{gravity=false,spawn_at_origin=true,duration=20,persistent=false})
     end
    end
    c.boss:play_sound_at_self('ENTITY_ARROW_SHOOT',.6,.7)
    s.wave=s.wave+1
    if s.wave>3 then s.rainAt=nil; s.busyUntil=s.tick+80
    else s.rainAt=s.tick+28; storm_cells(c,s) end
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Raincaller Instructor: &fThe wind has turned. Read the green lane again.'); return
  end
  if s.tick>=s.nextStorm then
   s.nextStorm=s.tick+380; s.center=player:get_location(); s.wave=1; s.rainAt=s.tick+44
   storm_cells(c,s); c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_FLUTE',.6,1)
  end
 end,
 on_player_damaged_by_boss=function(c) if c.event.projectile then c.event.multiply_damage_amount(.18) end end,
 on_death=function(c) c.boss:send_message('&6Raincaller Instructor: &fYou found the clear weather between the arrows.',24) end
}
