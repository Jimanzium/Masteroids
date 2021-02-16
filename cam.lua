local cam = {}
cam.x = 0
cam.y = 0
cam.scale = 0.5
cam.tscale = 1
cam.speed = 75

function cam_move(x,y)
	cam.x = cam.x + x * cam.speed
	cam.y = cam.y + y * cam.speed
end
local minScale = 0.025

function cam_setScale(x)
	cam.tscale = math.max(x,minScale)
end

function cam_setPos(x,y)
	local sw, sh = love.graphics.getDimensions()
	cam.x = x - sw/2 / cam.scale
	cam.y = y - sh/2 / cam.scale
end

function cam_getPos()
	return cam.x, cam.y
end

function cam_getScale()
	return cam.scale
end

function cam_reset()
	local x, y = planet_getPos(1)
	cam.scale = 20
	cam_setPos(x,y)

	cam.tscale = 0
end

local zoom = false

function get_zoom()
	return zoom
end

function cam_update(dt)

	if(zoom) then
		local sw, sh = screen()
		local worldW, worldH = get_world()
		cam.scale = (sw/2 / (worldW*1))*2

		cam_setPos(worldW/2, worldH/2)
		--cam.scale = 0.025
	else
		cam.scale = cam.scale + (cam.tscale - cam.scale) * 5 * dt
	end
end

function cam_keypressed(key)
	if(key == "space") then
		zoom = not(zoom)
	end
end

function cam_set()
	love.graphics.push()
	love.graphics.scale(cam.scale,cam.scale)
	love.graphics.translate(-cam.x, -cam.y)
end

function cam_unset()
	love.graphics.pop()
end