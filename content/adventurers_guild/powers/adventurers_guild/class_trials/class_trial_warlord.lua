-- @include ground_markers.inc
-- @include mobility/steed_charge.inc

-- Rally briefly protects two cadets, then orders them toward a marked anchor.
-- The stationary horn call is interruptible; separation defeats the protection.
return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location(); c.state.cadets={}
  for _,side in ipairs({-1,1}) do
   local cadet=c.world:spawn_custom_boss_at_location('class_trial_guardian_apprentice.yml',
    {x=p.x+side*3,y=p.y,z=p.z+2,world=p.world},{level=c.boss.level,add_as_reinforcement=true,silent=true})
   assert(cadet,'Warlord cadet could not spawn'); table.insert(c.state.cadets,cadet)
  end
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextRally=70; s.nextReform=260
   player:send_message('&6Warlord Instructor: &fListen for the horn. My people move together until you make them stop.')
  end
  if (s.auraUntil or 0)>s.tick and s.tick%5==0 then show_circle(c,s.aura,235,170,70) end
  if s.rallyAt then
   if s.tick%4==0 then show_circle(c,s.aura,235,170,70) end
   if s.tick>=s.rallyAt then
    s.rallyAt=nil; s.auraUntil=s.tick+100; s.busyUntil=s.tick+40
    for _,cadet in ipairs(s.cadets) do
     if cadet:is_alive() and s.aura:contains(cadet:get_location()) then cadet:apply_potion_effect('SPEED',60,0) end
    end
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.busyUntil=s.tick+65
   player:send_message('&6Warlord Instructor: &fThe line moves. Make your decision before we arrive.')
   steed_charge(c,player)
  elseif s.tick>=s.nextRally then
   s.nextRally=s.tick+360; s.rallyAt=s.tick+28; s.pressure=0
   s.aura=ground_circle(c,c.boss:get_location(),5)
   pause_movement(c,68); c.boss:play_sound_at_self('ITEM_GOAT_HORN_SOUND_0',.6,.8)
  elseif s.tick>=s.nextReform then
   s.nextReform=s.tick+400; s.busyUntil=s.tick+60
   local p=c.boss:get_location()
   for i,cadet in ipairs(s.cadets) do
    if cadet:is_alive() then cadet:navigate_to_location({x=p.x+(i==1 and -2 or 2),y=p.y,z=p.z-3,world=p.world},.8,false,60) end
   end
  end
 end,
 on_boss_damaged_by_player=function(c)
  if not c.state.rallyAt or c.event.is_damage_transfer then return end
  local s=c.state; s.pressure=s.pressure+c.event.get_damage_amount()
  if s.pressure>=c.boss:get_maximum_health()*.05 then
   s.rallyAt=nil; s.busyUntil=s.tick+50
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1)
   local player=c.players:current_target()
   if player then player:send_message('&6Warlord Instructor: &fA broken command. Take your opening.') end
  end
 end,
 on_reinforcement_damaged_by_player=function(c)
  local s=c.state
  if (s.auraUntil or 0)>(s.tick or 0) and s.aura:contains(c.event.entity:get_location()) then c.event.multiply_damage_amount(.8) end
 end,
 on_death=function(c) c.boss:send_message('&6Warlord Instructor: &fYou kept your head when the formation moved. Lead with that.',24) end
}
