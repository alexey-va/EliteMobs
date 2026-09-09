-- @include shared.inc
-- @include mobility/ranger.inc
-- @include abilities/ranger.inc

local ids={'paper_one','paper_two','paper_three'}
local function targets(c,s)
 local p=c.trial:position(); local x,z=T.direction(p,c.trial.player:get_location())
 for i,id in ipairs(ids) do
  c.trial:remove_actor(id)
  local side=i%2==0 and -1 or 1
  R.prop(c,s,id,T.offset(p,x*(2+i)-z*side*4,0,z*(2+i)+x*side*4),1,'&fPaper Training Target','WHITE_WOOL')
 end
end
local function flight(c,s)
 local angles={0}
 for i,id in ipairs(ids) do if c.trial:actor(id) then angles[#angles+1]=(i-2)*12+(i==2 and 6 or 0) end end
 return R.draw(c,s,{warn=36,lock=14,speed=1.1,damage=.45,cap=.9,recovery=50,angles=angles})
end
return T.encounter{
 init=function(c,s) R.init(c,s,false); targets(c,s) end,
 passive=function(c,s) R.passive(c,s); if s.markUntil>s.tick and s.tick%8==0 then local p=c.trial:position(); T.draw(c,T.lane(p,T.rotate(p,c.trial.player:get_location(),0,24),.2),R.feather) end end,
 choose=function(c,s)
  if s.phasePending and T.ready(s,'step') then s.phasePending=false; local seq=M.move(c,s); T.append(seq,{T.wait(1,nil,nil,targets),T.rest(30)}); T.start(c,s,'step',seq,M.cooldown)
  elseif T.ready(s,'sight') then T.start(c,s,'sight',R.mark(c,s,26,120),400)
  elseif T.ready(s,'flight') then T.start(c,s,'flight',flight(c,s),280)
  else R.basic(c,s) end
 end
}
