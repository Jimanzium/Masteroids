
local mouseLastX, mouseLastY = 0,0
local controls = 1

local rAccum = 0

local rAccumSpeed = 1

function player_reset()
	rAccum = 0
end

function player_update(dt)
	local planet = get_planet(controls)
	local mx, my = love.mouse.getPosition()

	rAccum = rAccum + (planet.accum - rAccum) * rAccumSpeed * dt

	if(love.keyboard.isDown("o")) then
		planet.r = planet.r + planet.r * 0.1 * dt + 100 * dt
	end

	if(love.mouse.isDown(2)) then
		--cam_move((mx - mouseLastX) * -dt, (my - mouseLastY) * -dt)
	end

	--cam_setPos(planet_getPos(controls))

	local cx, cy = cam_getPos()
	x = mx / cam_getScale() + cx
	y = my / cam_getScale() + cy 
	local px, py = planet_getPos(controls)
	local a = math.atan2(py - y, px - x) + math.pi

	if(love.mouse.isDown(1)) then
		local dx = math.cos(a) * dt
		local dy = math.sin(a) * dt

		planet_thrust(controls, dx, dy)
	end

	if(love.mouse.isDown(2)) then
		planet.cannonAngle = a
		planet_shoot(controls)
	end

	local sw, sh = screen()
	local scale = 1
	local tr = sw * 0.05/2
	scale = tr/planet.r

	if(planet.dead == true or planet.r < 10) then
		local worldW, worldH = get_world()
		scale = (sw/2 / (worldW*1.05))*2
		planet.x = worldW/2
		planet.y = worldH/2
	end
	
	cam_setScale(scale)

	--[[
	local scale = 1
	if(planet.r > 200) then
		scale = 0.5
	elseif(planet.r > 100) then
		scale = 0.75
	end
	
	]]

	love.audio.setPosition(planet.x/100, planet.y/100, 0)

	mouseLastX, mouseLastY = mx, my
end

function get_player()
	return controls
end

function player_keypressed(key)
	if(key == "a") then
		controls = controls - 1
		if(controls == 0) then
			controls = get_numPlanets()
		end
	elseif(key == "d") then
		controls = controls + 1
		if(controls > get_numPlanets()) then
			controls = 1
		end
	end
end

function player_mousepressed(x,y,button)

	if(button == 1) then
		local planet = get_planet(controls)
		if(planet.dead) then
			set_menuCol(planet.c)
			reset()
			set_state("menu")
		end
	end
end

function player_UI()
	local planet = get_planet(controls)
	local mx, my = love.mouse.getPosition()
	love.graphics.setColor(planet.c)

	love.graphics.circle("fill",mx,my,10)

	local sw, sh = screen()

	

	love.graphics.setColor(30,30,30)
	local speed = math.floor(planet_getSpeed(controls)*100)/100
	love.graphics.print("PLANET: "..controls..", MASS: "..(math.floor(planet.r*100)/100)..", SPEED: "..speed..", ACCUM: "..(math.floor(planet.accum*100)/100),2,sh-20)

	
	--love.graphics.print(speed)

	local h = 10
	local maxSpeed = 2000
	local w = math.min(speed/maxSpeed,1) * maxSpeed
	w = w^1.1

	love.graphics.setColor(100 + w/maxSpeed * 155,0,0)
	--love.graphics.rectangle("fill",sw/2 - w/2,2,w,h)

	love.graphics.setColor(255,255,255)

	if(planet.dead and get_gameType() == "surv") then
		love.graphics.setColor(planet.c[1]*0.5,planet.c[2]*0.5,planet.c[3]*0.5)
		cprint("Total Mass Accumulated: "..(math.floor(planet.accum*100)/100), sw/2 - 4, sh/2 - 4,3)
		love.graphics.setColor(planet.c)
		cprint("Total Mass Accumulated: "..(math.floor(planet.accum*100)/100), sw/2, sh/2,3)
	end

	

	local accum = math.floor(rAccum)
	local s = 2 + math.min(3,(planet.accum - rAccum))
	love.graphics.setColor(planet.c[1]*0.5,planet.c[2]*0.5,planet.c[3]*0.5)
	cprint(accum, sw/2 - 4, 100 - 4, s)
	love.graphics.setColor(planet.c)
	cprint(accum, sw/2, 100, s)

	love.graphics.setColor(planet.c[1]*0.5,planet.c[2]*0.5,planet.c[3]*0.5)
	cprint(math.floor(planet.r).." / "..get_maxSize(), sw/2 - 4, sh - 100 - 4, 2)
	love.graphics.setColor(planet.c)
	cprint(math.floor(planet.r).." / "..get_maxSize(), sw/2, sh - 100, 2)
	love.graphics.setColor(255,255,255)
end

function player_draw()
	
end