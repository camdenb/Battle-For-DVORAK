cam = require('lib/camera')
vector = require('lib/vector')
Gamestate = require('lib/gamestate')

require('overworld')
require('battle')

function love.load()

	WINDOW_HEIGHT = 500
	WINDOW_WIDTH = 500

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {resizable=true, vsync=enableVsync, fsaa=0})
	love.window.setTitle('typing RL')
	love.graphics.setBackgroundColor(255, 255, 255)

	love.keyboard.setKeyRepeat(true)

	Gamestate.registerEvents()
	Gamestate.switch(battle)

end

function love.resize(w, h)
	WINDOW_HEIGHT = h
	WINDOW_WIDTH = w
end

function love.update(dt)

	

end

function love.draw()
	
end

function love.keypressed(key)

end

function tick()
	
end

function takeScreenshot(string)
	print(string)
	local scrot = love.graphics.newScreenshot()
	if love.filesystem.exists(string .. '-' .. os.date('%m-%d_%H-%M-%S') .. '.png') then
		scrot:encode(string .. '-' .. os.date('%m-%d_%H-%M-%S') .. '-' .. tostring(math.random(1,100)) .. '.png', 'png')
	else
		scrot:encode(string .. '-' .. os.date('%m-%d_%H-%M-%S') .. '.png', 'png')
	end
end