cam = require('lib/camera')
vector = require('lib/vector')
Gamestate = require('lib/gamestate')

require('overworld')
require('battle')

local tickCounter = 0
local tickMax = 60

function love.load()

	WINDOW_HEIGHT = 500
	WINDOW_WIDTH = 500

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {resizable=true, vsync=enableVsync, fsaa=0})
	love.window.setTitle('typing RL')
	love.graphics.setBackgroundColor(255, 255, 255)

	love.keyboard.setKeyRepeat(true)

	Gamestate.registerEvents()
	Gamestate.switch(overworld)

end

function love.resize(w, h)
	WINDOW_HEIGHT = h
	WINDOW_WIDTH = w
end

function love.update(dt)

	tickCounter = tickCounter + 1
	if tickCounter >= tickMax then
		tick()
		tickCounter = 0
	end

end

function love.draw()
	
end

function love.keypressed(key)

end

function tick()
	
end
