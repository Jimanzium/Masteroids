local ais = {}

function reset_ais()
	ais = {}
end

local controls = {}

function add_ai(c)
	local a = {controls = c, angle = 0, timer = 0}
	table.insert(ais,a)
end

function ai_update(dt)
	for i,v in ipairs(ais) do
		local planet = get_planet(v.controls)

		v.timer = v.timer - dt
		if(v.timer <= 0) then
			v.angle = math.random(0,math.pi*2*100)/100
			v.timer = v.timer + 10
		end

		local dx = math.cos(v.angle)
		local dy = math.sin(v.angle)
		planet_thrust(v.controls, dx * dt, dy * dt)
	end

	--[[
	local numPlanets = get_numPlanets()
	for i=1,numPlanets do
		if(isControlled(i)) then
			local planet = get_planet(i)
			planet_thrust(i, 100 * dt, 100 * dt)
		end
	end
	]]
end

function ai_draw()

end

function isControlled(i)
	for j=1,#controls do
		if(i == controls[j]) then
			return true
		end
	end
	return false
end