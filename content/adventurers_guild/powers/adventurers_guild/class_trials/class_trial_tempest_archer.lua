-- @include shared.inc
-- @include mobility/ranger.inc
-- @include abilities/ranger.inc

-- Two committed crosswinds with a visible lateral reposition between volleys.
-- Each draw locks independently, so a challenger can dodge the first and read the second.
local function cyclone(c,s)
 local first=R.draw(c,s,{warn=36,lock=16,angles={-12,12},damage=.4,cap=.65,speed=.9,recovery=20})
 T.append(first,M.move(c,s))
 local second=R.draw(c,s,{warn=30,lock=14,angles={-8,8},damage=.4,cap=.65,speed=1,recovery=60,
  result=function(c,s,hit)
   if not hit then s.markUntil=0; c.trial:say('You found the quiet air between them.') end
  end})
 T.append(first,second)
 return first
end
return T.encounter{
 init=function(c,s) R.init(c,s,false) end,
 passive=function(c,s) R.passive(c,s); s.approachSpeed=s.markUntil>s.tick and .253 or .22 end,
 choose=function(c,s)
  if s.phasePending and T.ready(s,'step') then s.phasePending=false; T.start(c,s,'step',M.move(c,s),M.cooldown)
  elseif T.ready(s,'mark') then T.start(c,s,'mark',R.mark(c,s,28,120),440)
  elseif T.ready(s,'cyclone') then T.start(c,s,'cyclone',cyclone(c,s),360)
  else R.basic(c,s) end
 end
}
