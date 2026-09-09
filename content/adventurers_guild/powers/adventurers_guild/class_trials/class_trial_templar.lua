-- @include ground_markers.inc
-- @include mobility/steed_charge.inc
-- @include abilities/judgment.inc

return {
 api_version=1,
 on_spawn=function(c)
  local p=c.boss:get_location()
  c.state.novice=c.world:spawn_custom_boss_at_location('class_trial_guardian_apprentice.yml',
   {x=p.x+3,y=p.y,z=p.z+2,world=p.world},{level=c.boss.level,add_as_reinforcement=true,silent=true})
  assert(c.state.novice,'Templar novice could not spawn')
 end,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextJudgment=65; s.nextBell=240; s.heals=0
   player:send_message('&6Templar Instructor: &fHear the bell. You can silence it before its promise is fulfilled.')
  end
  if s.tick%5==0 then show_judgment(c) end
  if s.bellAt then
   if s.tick%12==0 then c.boss:play_sound_at_self('BLOCK_BELL_USE',.55,1) end
   if s.tick>=s.bellAt then
    s.bellAt=nil; s.busyUntil=s.tick+40
    if s.novice and s.novice:is_alive() and s.heals<3 then
     s.novice:restore_health(s.novice:get_maximum_health()*.25); s.heals=s.heals+1
     s.novice:apply_potion_effect('RESISTANCE',60,0)
    end
   end
   return
  end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.busyUntil=s.tick+65; steed_charge(c,player)
   player:send_message('&6Templar Instructor: &fA vow means little if it arrives too late.')
  elseif s.tick>=s.nextJudgment then
   judgment(c,.9); s.nextJudgment=s.tick+400
  elseif s.tick>=s.nextBell and s.novice and s.novice:is_alive() and s.heals<3 then
   s.nextBell=s.tick+440; s.bellAt=s.tick+36; s.channelDamage=0
   pause_movement(c,76)
  end
 end,
 on_boss_damaged_by_player=function(c)
  weigh_judgment(c)
  local s=c.state
  if not s.bellAt or c.event.is_damage_transfer then return end
  s.channelDamage=s.channelDamage+c.event.get_damage_amount()
  if s.channelDamage>=c.boss:get_maximum_health()*.05 then
   s.bellAt=nil; s.busyUntil=s.tick+40
   c.boss:play_sound_at_self('BLOCK_GLASS_BREAK',.5,1.5)
   local player=c.players:current_target()
   if player then player:send_message('&6Templar Instructor: &fYou silenced the bell. Use the moment.') end
  end
 end,
 on_death=function(c) c.boss:send_message('&6Templar Instructor: &fYou heard the warning and answered it. Well fought.',24) end
}
