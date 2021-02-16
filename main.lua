--love.graphics.setDefaultFilter("nearest","nearest")

require "world"
require "cam"
require "player"
require "planets"
require "ai"
require "effects"

local music = love.audio.newSource("music.ogg")
music:setLooping(true)
music:play()

local state = "menu"
function set_state(s)
	state = s
end
local gameType = ""
function get_gameType()
	return gameType
end

local font1 = love.graphics.newFont("font.ttf", 12)
love.graphics.setFont(font1)

function love.load()

	--love.audio.setDistanceModel("exponent")
	love.graphics.setBackgroundColor(10,10,10)
	math.randomseed(os.time())

end

function reset()
	math.randomseed(os.time())
	reset_ais()
	reset_world()
	player_reset()
	reset_planets()
	world_new()
	--cam_reset()
end

function load_sim()
	load_survival()
	add_ai(1)
	gameType = "sim"
end

function load_survival()
	reset()
	local worldW, worldH = get_world()
	add_planet(math.random(1,worldW), math.random(1,worldH),15)
	for i=1,25 do
		local x, y = math.random(1,worldW), math.random(1,worldH)
		add_planet(x,y,math.random(15,15))
		add_ai(1+i)
	end
	gameType = "surv"
end



function love.update(dt)
	if(love.keyboard.isDown("p")) then
		dt = dt * 10
	end


	if(state == "menu") then

	elseif(state == "play"and love.keyboard.isDown("/") == false) then
		world_update(dt)
		planets_update(dt)
		player_update(dt)
		ai_update(dt)

		effects_update(dt)

		cam_setPos(planet_getPos(get_player()))
		cam_update(dt)
	end
end

function love.keypressed(key)
	if(key == "escape") then
		love.event.quit()
	elseif(key == "r") then
		reset()
		state = "menu"
	else
		cam_keypressed(key)
		player_keypressed(key)
	end
end

function love.mousepressed(x,y,button)

	if(state == "menu") then
		if(button == 1) then
			local sw, sh = screen()
			if(x < sw/2) then
				load_survival()
				state = "play"
			else
				load_sim()
				state = "play"
			end
		end
	elseif(state == "play") then
		player_mousepressed(x,y,button)
	end
end

local spaceImg = love.graphics.newImage("back.png")
local menuCol = {math.random(1,255),math.random(1,255),math.random(1,255)}

function set_menuCol(c)
	menuCol = {c[1],c[2],c[3]}
end

function love.draw()
	local sw, sh = screen()

	if(state == "menu") then
		love.graphics.setColor(menuCol)
		love.mouse.setVisible(true)
		cprint("MASSTEROIDS",sw/2,sh*1/4,3)
		local s = love.mouse.getX() - (sw*1/3)
		s = math.abs(200/s)
		s = math.max(2,s)
		s = math.min(s, 5)
		cprint("SURVIVAL", sw*1/3, sh/2, s)
		local s = love.mouse.getX() - (sw*2/3)
		s = math.abs(200/s)
		s = math.max(2,s)
		s = math.min(s, 5)
		cprint("SIMULATION", sw*2/3, sh/2,s)
		love.graphics.setColor(255,255,255)
	elseif(state == "play" ) then
		love.mouse.setVisible(false)
		cam_set()

		-- draw grid ---
		local scale = cam_getScale()
		local a = 5
		love.graphics.setColor(255,255,255, a)

		local sw, sh = screen()

		local cx,cy = cam_getPos()
		local tw = 600
		local th = 600
		local x = math.floor((cx)/tw)*tw
		local y = math.floor(cy/th)*th
		local worldW, worldH = get_world()
		for i=0,(sw/scale)/tw + 1 do
			for j=0,(sh/scale)/th + 1 do
				local x2, y2 = x + i * tw, y + j * th
				if(x2 >= 0 and y2 >= 0 and x2 <= worldW and y2 < worldH) then
					--love.graphics.rectangle("line",x2,y2,tw,th)
					love.graphics.draw(spaceImg,x2,y2)
				end
			end
		end

		love.graphics.setColor(255,255,255)

		----
		planets_drawPull()

		player_draw()
		planets_draw()
		world_draw()
		ai_draw()

		effects_draw()

		cam_unset()

		if(get_zoom() == false) then
			player_UI()
		end
	end

	love.graphics.setColor(30,30,30)
	love.graphics.print(love.timer.getFPS())
	love.graphics.setColor(255,255,255)
end

function screen()
	return love.graphics.getDimensions()
end

function get_dist(x1,y1,x2,y2)
	return math.sqrt((x2-x1)^2 + (y2-y1)^2)
end

function cprint(text,x,y,scale)
	if not(scale) then
		scale = 1
	end
	local f = love.graphics.getFont()
	local w = f:getWidth(text)
	local h = f:getHeight(text)

	love.graphics.push()
	
	--love.graphics.scale(scale)
	love.graphics.translate(x-w/2*scale,y-h/2*scale)
	love.graphics.scale(scale)
	love.graphics.print(text, 0, 0)

	love.graphics.pop()
end