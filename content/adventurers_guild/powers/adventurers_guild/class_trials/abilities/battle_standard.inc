-- A real reinforcement owns its stats and appearance in YAML. Its banner grants
-- protection to nearby allies; destroying it removes that advantage immediately.
local function banner_alive(s)
 return s.standard and s.standard:is_alive() and (s.standardUntil or 0)>s.tick
end
local function within_banner(s,entity)
 if not banner_alive(s) then return false end
 local a,b=s.standard:get_location(),entity:get_location()
 return (a.x-b.x)^2+(a.z-b.z)^2<=25
end
