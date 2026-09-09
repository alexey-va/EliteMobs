-- @include ground_markers.inc
-- @include mobility/steed_charge.inc
-- @include abilities/judgment.inc

return {
 api_version=1,
 on_game_tick=function(c)
  local player=c.boss:get_target_player()
  if not player or not player:is_alive() then return end
  local s=c.state; s.tick=(s.tick or 0)+1
  if not s.started then
   s.started=true; s.nextJudgment=60; s.nextCensure=230
   player:send_message('&6Justicar Instructor: &fEvery blow weighs upon the scales. Choose when to commit.')
  end
  if s.tick%5==0 then show_judgment(c) end
  if s.tick<(s.busyUntil or 0) then return end
  if not s.phaseTwo and c.boss:get_health()<=c.boss:get_maximum_health()*.5 then
   s.phaseTwo=true; s.busyUntil=s.tick+65; s.nextJudgment=s.tick+65
   player:send_message('&6Justicar Instructor: &fJudgment follows. Do not stand before it.')
   steed_charge(c,player)
  elseif s.tick>=s.nextJudgment then
   judgment(c,1.2); s.nextJudgment=s.tick+360
  elseif s.tick>=s.nextCensure then
   s.nextCensure=s.tick+320; s.busyUntil=s.tick+56
   local zone=ground_circle(c,c.boss:get_location(),4)
   c.boss:set_ai_enabled(false,56); c.boss:play_sound_at_self('BLOCK_BELL_USE',.5,.85)
   local age,task=0,nil
   task=c.scheduler:run_repeating(0,4,function()
    show_circle(c,zone,245,215,110); age=age+4
    if age>=24 then c.scheduler:cancel(task) end
   end)
   c.scheduler:run_later(26,function()
    for _,target in ipairs(zone:full_target():entities()) do target:apply_potion_effect('WEAKNESS',60,0) end
   end)
  end
 end,
 on_boss_damaged_by_player=weigh_judgment,
 on_death=function(c)
  c.boss:send_message('&6Justicar Instructor: &fMeasured strength. A sound judgment.',24)
 end
}
