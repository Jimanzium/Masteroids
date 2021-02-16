

local planets = {}

local maxSize = 1250

function get_maxSize()
	return maxSize
end

function reset_planets()
	planets = {}
end

function add_planet(x,y,r)
	local p = {x=x,y=y,r=r,
			c={math.random(1,255), math.random(1,255), math.random(1,255)},
			xvel=0,yvel=0,
			thrust = 200,
			dead = false,
			cannonAngle = 0,
			cannonCd = 0,
			sr = r,
			accum = 0, -- total mass acumulated
			lastR = r
			}
	table.insert(planets,p)

end

function get_numPlanets()
	return #planets
end

function get_planet(i)
	return planets[i]
end

function planet_getPos(i)
	return planets[i].x, planets[i].y
end

function planet_getSpeed(i)
	return math.sqrt(planets[i].xvel^2 + planets[i].yvel^2)
end

function planet_setCannonAngle(i,x)
	planets[i].cannonAngle = x
end

function planet_thrust(planet, xvel, yvel)
	local planet = planets[planet]
	planet.xvel = planet.xvel + xvel * planet.thrust
	planet.yvel = planet.yvel + yvel * planet.thrust
end

local cannonCd = 1

function planet_shoot(i)
	local planet = planets[i]
	if(planet.cannonCd <= 0 and planet.r >= 20) then
		planet.r = planet.r - 10
		local dx = math.cos(planet.cannonAngle) * planet.r * 1.2
		local dy = math.sin(planet.cannonAngle) * planet.r * 1.2
		add_body(planet.x + dx, planet.y + dy, planet.r * 0.15 * 4,true, dx * 10, dy * 10)
		planet.cannonCd = cannonCd
		planet.r = planet.r * 0.85
	end
	
end

local growSpeed = 10
local terminalVel = 1000
local terminalScale = 1
local slowDown = 1000
function planets_update(dt)
	for i,v in ipairs(planets) do

		v.sr = v.sr + (v.r - v.sr) * growSpeed * dt

		v.thrust = 120 + v.r/2

		if(v.dead == false) then

		v.cannonCd = math.max(0, v.cannonCd - dt)
		if not(v.trail) then
			local trailSize = 60

			v.trail = {}
			for j=1,trailSize do
				v.trail[j] = {x=v.x,y=v.y}
			end
		else
			for j=#v.trail,1,-1 do
				if(j == 1) then
					v.trail[j].x, v.trail[j].y = v.x, v.y
				else
					v.trail[j].x, v.trail[j].y = v.trail[j - 1].x, v.trail[j - 1].y
				end
			end

			if(math.min(200,v.r/10) > #v.trail) then
				v.trail[#v.trail+1] = {v.trail[#v.trail].x, v.trail[#v.trail].y}
			end
		end


		local numBodies = get_numBodies()

		for j = 1, numBodies do
			local body = get_body(j)
			if(body.fired == false) then
				local d = get_dist(v.x,v.y,body.x, body.y)
				local pullRange = v.r * 5

				if(d < pullRange) then
					local a = math.atan2(v.y - body.y, v.x - body.x)
					local dx = math.cos(a) * 1/d * 10000 * v.r/25
					local dy = math.sin(a) * 1/d * 10000 * v.r/25

					body.xvel = body.xvel + dx * dt
					body.yvel = body.yvel + dy * dt
				end

				if(d <= v.r + body.r and body.life == 0) then
					planet_clash(v, body)
					v.r = v.r + body.r/4
					body.r = 0
				end
			else
				local d = get_dist(v.x,v.y,body.x, body.y)
				if(d < v.r + body.r and body.life == 0) then
					local loss = v.r * 0.15 * 4
					local a = math.atan2(body.yvel, body.xvel) + math.pi
					local dx = math.cos(a) * body.r * 10
					local dy = math.sin(a) * body.r * 10
					for l = 1,3 do
						add_body(body.x, body.y, loss/3, false, dx + math.random(-50,50), dy+ math.random(-50,50))
					end
					v.r = v.r * 0.85
					body.r = 0
				end
			end
		end


		for j,k in ipairs(planets) do
			if (i~=j and k.dead == false) then
				local d1 = get_dist(v.x ,v.y,k.x,k.y)
				local d = get_dist(v.x + v.xvel * dt,v.y + v.yvel * dt,k.x + k.xvel * dt,k.y + k.yvel*dt)
				if(v.r > k.r and d < v.r * 5) then
					local a = math.atan2(v.y - k.y, v.x - k.x)
					local dx = math.cos(a)
					local dy = math.sin(a)
					k.xvel = k.xvel + dx * 1/d * 5000
					k.yvel = k.yvel + dy * 1/d * 5000
				end
				if(d <= v.r + k.r) then
					

					if(v.r > k.r) then
						reflect(v,k)
						planet_clash(v,k)
					else
						reflect(k,v)
						planet_clash(k,v)
					end

					--[[
					local m1 = v.r * math.sqrt(v.xvel^2 + v.yvel^2)
					local m2 = k.r * math.sqrt(k.xvel^2 + k.yvel^2)

					local transfer = 1
					if(v.r > k.r) then
						k.xvel = k.xvel + transfer * v.xvel
						k.yvel = k.xvel + transfer * v.yvel
						v.xvel = v.xvel * (1-transfer)
						v.yvel = v.yvel * (1-transfer)
					else
						v.xvel = v.xvel + transfer * k.xvel
						v.yvel = v.yvel + transfer * k.yvel
						k.xvel = k.xvel * (1-transfer)
						k.yvel = k.yvel * (1-transfer)						
					end

					]]--

					--[[
					v.xvel = -v.xvel * 0.75
					v.yvel = -v.yvel * 0.75
					k.xvel = -k.xvel * 0.75
					k.yvel = -k.yvel * 0.75

					if(v.r > k.r) then
						v.r = v.r + k.r * 0.2
						k.r = k.r * 0.8
					elseif(k.r > v.r) then
						k.r = k.r + v.r * 0.2
						v.r = v.r * 0.8
					end
					]]
				end
			end
		end
		-- terminal vel -----------------------------------
		local vel = math.sqrt(v.xvel^2 + v.yvel^2)
		if(vel > terminalVel + v.r * terminalScale) then
			local a = math.atan2(v.yvel, v.xvel) + math.pi
			local dx = math.cos(a) * slowDown * dt
			local dy = math.sin(a) * slowDown * dt
			v.xvel = v.xvel + dx
			v.yvel = v.yvel + dy
		end
		--------------------------------------------------

		if(v.r > v.lastR) then
			v.accum = v.accum + (v.r - v.lastR)
		end

		v.lastR = v.r

		v.x, v.y, v.xvel, v.yvel = world_col(v.x,v.y,v.xvel,v.yvel,v.r,dt)

		v.x = v.x + v.xvel * dt
		v.y = v.y + v.yvel * dt

		if(v.r > maxSize) then
			for i=1,v.r/25 do
				local x = v.x + math.random(-v.r,v.r) * 0.25
				local y = v.y + math.random(-v.r,v.r) * 0.25
				local a = math.random(0,2*math.pi*100)/100
				local v = math.random(500,1000)
				local dx, dy = math.cos(a) * v, math.sin(a) * v
				add_body(x,y,25*4,false,dx,dy)
			end
			v.r = 0
		elseif(v.r <= 10) then
			v.r = 0
			v.dead = true
		end
	end
	end
end


function reflect(v,k)
	local transfer = 0.25

	local m1 = math.sqrt(v.xvel^2 + v.yvel^2)
	local m2 = math.sqrt(k.xvel^2 + k.yvel^2)

	local a = math.atan2(v.y - k.y, v.x - k.x) + math.pi
	local a2 = math.atan2(k.xvel, k.yvel)

	local a3 = a2 + (a-a2)

	k.xvel = math.cos(a3) * (m2+m1/2)
	k.yvel = math.sin(a3) * (m2+m1/2)

	v.xvel = v.xvel * (1-transfer)
	v.yvel = v.yvel * (1-transfer)

	v.r = v.r + k.r * transfer
	k.r = k.r * (1-transfer)
end

local pullImg = love.graphics.newImage("pull.png")

function planets_drawPull()
	for i,v in ipairs(planets) do
		
		love.graphics.setBlendMode("add")
		--[[
		for j=1,20 do -- math.floor(v.r*5) do
			love.graphics.setColor(v.c[1],v.c[2],v.c[3],j/20*25)
			love.graphics.circle("fill",v.x,v.y,j/20 * v.r*5)
		end
		]]
		love.graphics.setColor(v.c[1],v.c[2],v.c[3],150)
		local scale = (v.sr*15)/pullImg:getWidth()

		
		for j=1,2 do 
			love.graphics.draw(pullImg, v.x, v.y, 0, scale*j/2, scale*j/2,pullImg:getWidth()/2, pullImg:getHeight()/2)
		end


		if(v.trail ) then
			for j=#v.trail,1,-1 do
				local p = (1-(j/#v.trail))
				local scale = (v.sr*2.5*p)/pullImg:getWidth()
				love.graphics.setColor(v.c[1], v.c[2] , v.c[3], 155*p)

				love.graphics.draw(pullImg, v.trail[j].x, v.trail[j].y, 0, scale, scale,pullImg:getWidth()/2, pullImg:getHeight()/2)
				
				
				--love.graphics.circle("fill",v.trail[j].x, v.trail[j].y, v.r * p)
			end
		end
		love.graphics.setBlendMode("alpha")
	end
	love.graphics.setColor(255,255,255)
end

function planets_draw()
	for i,v in ipairs(planets) do



		
		love.graphics.setColor(v.c[1] * 0.8,v.c[2] * 0.8,v.c[3] * 0.8)
		---love.graphics.circle("fill",v.x,v.y,v.sr * 1.1)

		love.graphics.setColor(v.c)
		love.graphics.circle("fill",v.x,v.y,v.sr)

		love.graphics.setBlendMode("add")
		love.graphics.setColor(v.c[1],v.c[2],v.c[3])
		local scale = (v.sr*2)/pullImg:getWidth()
		love.graphics.draw(pullImg, v.x, v.y, 0, scale, scale,pullImg:getWidth()/2, pullImg:getHeight()/2)

		love.graphics.setBlendMode("alpha")

		love.graphics.setColor(255,255,255)
		local dx = math.cos(v.cannonAngle) * v.sr * 1.2
		local dy = math.sin(v.cannonAngle) * v.sr * 1.2
		--love.graphics.circle("fill",v.x + dx,v.y + dy,v.r*0.1)
	end
	love.graphics.setColor(255,255,255)
end