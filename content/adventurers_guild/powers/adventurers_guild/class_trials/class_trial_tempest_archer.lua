-- @include mobility/windstep.inc
-- @include abilities/arrow_lanes.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player(); if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextMark=40; s.nextCyclone=130
   player:send_message('&6Tempest Archer Instructor: &fTwo crosswinds. The second begins where the first leaves me.')
  end
  if (s.markUntil or 0)>s.tick and s.tick%10==0 then player:spawn_particle_at_self({particle='END_ROD',amount=1},1) end
  if s.fireAt then
   if s.tick<s.lockAt then s.aim=player:get_eye_location(); c.boss:face_direction_or_location(s.aim) end
   local angles=s.second and {-8,8} or {-12,12}
   if s.tick%4==0 then arrow_lanes(c,s.aim,angles,1,false) end
   if s.tick>=s.fireAt then
    arrow_lanes(c,s.aim,angles,1,true)
    if not s.second then
     s.second=true; windstep(c,player,s.tick); s.fireAt=s.tick+34; s.lockAt=s.tick+20; s.aim=player:get_eye_location()
    else s.fireAt=nil; s.second=nil; s.busyUntil=s.tick+120 end
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; windstep(c,player,s.tick); s.busyUntil=s.tick+30
   player:send_message('&6Tempest Archer Instructor: &fThere is quiet air between them. Find it again.'); return
  end
  if s.tick>=s.nextMark then
   s.nextMark=s.tick+440; s.busyUntil=s.tick+48; c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_FLUTE',.6,1.5)
   c.scheduler:run_later(28,function() s.markUntil=s.tick+180 end)
  elseif s.tick>=s.nextCyclone then
   s.nextCyclone=s.tick+360; s.fireAt=s.tick+38; s.lockAt=s.tick+22; s.aim=player:get_eye_location()
   c.boss:play_sound_at_self('BLOCK_NOTE_BLOCK_HARP',.6,.7)
  end
 end,
 on_player_damaged_by_boss=function(c)
  if c.event.projectile then c.event.multiply_damage_amount((c.state.markUntil or 0)>(c.state.tick or 0) and .35 or .3) end
 end,
 on_death=function(c) c.boss:send_message('&6Tempest Archer Instructor: &fYou found the quiet air between them.',24) end
}
