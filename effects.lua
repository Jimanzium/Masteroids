
local clashes = {}

function add_clash(x,y,r,a,c)
	local c = {x=x,y=y,r=r,timer = 0,a = a,c=c,spin = math.random(-10,10)/10}
	table.insert(clashes,c)
end

local note = love.audio.newSource("note.ogg")

function planet_clash(v,k)
	--note:setPosition(v.x/100, v.y/100, 0)
	--note:stop()
	--note:play()

	local a = math.atan2(v.y - k.y, v.x - k.x) + math.pi
	local dx = math.cos(a) * v.r
	local dy = math.sin(a) * v.r

	add_clash(v.x + dx, v.y + dy, (v.r+k.r)/2 * 3.5,a + math.pi/2,{v.c[1], v.c[2], v.c[3]})

	for i=1,3 do
		add_clash(v.x + dx, v.y + dy, v.r * math.random(5,10)/10, math.random(0,2*math.pi*100)/100,{v.c[1], v.c[2], v.c[3]})
	end
end

local clashSpeed = 10



function effects_update(dt)
	for i,v in ipairs(clashes) do
		v.a = v.a + dt/2
		v.timer = v.timer + (1 - v.timer) * clashSpeed * dt
		if(v.timer >= 1) then
			table.remove(clashes, i)
		end
	end
end

local glowImg = love.graphics.newImage("pull.png")

function effects_draw()
	love.graphics.setBlendMode("add")
	for i,v in ipairs(clashes) do
		love.graphics.setColor(v.c[1], v.c[2], v.c[3], 255*(1-v.timer))
		local scale =(v.r * v.timer) / glowImg:getWidth()
		love.graphics.draw(glowImg, v.x, v.y, v.a, scale*10, scale/2, glowImg:getWidth()/2, glowImg:getHeight()/2)
		love.graphics.draw(glowImg, v.x, v.y, v.a, scale*2, scale*2, glowImg:getWidth()/2, glowImg:getHeight()/2)
	end
	love.graphics.setBlendMode("alpha")

	love.graphics.setColor(255,255,255)
end