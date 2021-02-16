local bodies = {}

function reset_world()
	bodies = {}
end

function add_body(x,y,r,fired,xvel,yvel)
	if(fired) then
		local b = {x=x,y=y,r = r,xvel=xvel,yvel=yvel,fired = true}
		table.insert(bodies,b)
	else
		if(xvel and yvel) then
			local b = {x=x,y=y,r = r,xvel=xvel,yvel=yvel, fired = false}
			table.insert(bodies,b)
		else
			local b = {x=x,y=y,r = r,xvel=0,yvel=0, fired = false}
			table.insert(bodies,b)
		end
	end
end

local worldW = 1280 * 30 -- 40
local worldH = 720 * 30

function get_world()
	return worldW, worldH
end

function world_col(x,y,xvel,yvel,r,dt)
	if(x + xvel * dt < 0 or x + xvel * dt > worldW) then
		xvel = -xvel * 0.5
	end

	if(y+ yvel * dt < 0 or y + yvel * dt > worldH) then
		yvel = -yvel * 0.5
	end

	if(x > worldW) then x = worldW elseif(x < 0) then x = 0 end
	if(y > worldH) then y = worldH elseif(y < 0) then y = 0 end

	return x,y,xvel,yvel
end

local numBodies = 950 --1250

function get_numBodies()
	return #bodies
end

function get_body(i)
	return bodies[i]
end

function world_new()
	for i=1,numBodies*0.75 do
		local r = math.random(10,40)
		local x, y = math.random(1,worldW), math.random(1,worldH)
		add_body(x,y,r)
	end

	for i=1,numBodies*0.25 do
		local r = math.random(40,100)
		local x, y = math.random(1,worldW), math.random(1,worldH)
		add_body(x,y,r)
	end
end

function world_update(dt)
	for i,v in ipairs(bodies) do
		if not(v.life) then
			v.life = 0.25
		end
		v.life = math.max(0,v.life - dt)

		v.x, v.y, v.xvel, v.yvel = world_col(v.x,v.y,v.xvel,v.yvel,v.r,dt)

		v.x = v.x + v.xvel * dt
		v.y = v.y + v.yvel * dt

		if(v.r == 0) then
			table.remove(bodies,i)
		end
	end
end

local glowImg = love.graphics.newImage("pull.png")

function world_draw()
	--if(love.keyboard.isDown("/") == false) then
	for i,v in ipairs(bodies) do

		love.graphics.setBlendMode("add")
		love.graphics.setColor(36,18,0)
		love.graphics.circle("fill",v.x,v.y,v.r)
		local scale = (v.r*5)/glowImg:getWidth()
		love.graphics.draw(glowImg, v.x, v.y,0,scale,scale,glowImg:getWidth()/2, glowImg:getHeight()/2)
		love.graphics.setColor(65,32,0)
		local scale = ((v.r)*2)/glowImg:getWidth()
		love.graphics.draw(glowImg, v.x, v.y,0,scale,scale,glowImg:getWidth()/2, glowImg:getHeight()/2)
		love.graphics.setBlendMode("alpha")

		--[[
		love.graphics.setColor(36,18,0)
		love.graphics.circle("fill",v.x,v.y,v.r)
		love.graphics.setColor(65,32,0)
		love.graphics.circle("fill",v.x,v.y,v.r - 4)
	
		]]--
	end
	--end
	love.graphics.setColor(255,255,255)
end