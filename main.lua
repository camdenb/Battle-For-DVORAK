cam = require('lib/camera')
vector = require('lib/vector')
Gamestate = require('lib/gamestate')
Signals = require('lib/signal')
Timer = require('lib/timer')

require('lib/slam')

require('overworld')
require('battle')
require('midscreen')
require('inputbar')
require('title')

function love.load()

	WINDOW_HEIGHT = 500
	WINDOW_WIDTH = 500

	love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {resizable=true, vsync=enableVsync, fsaa=0})
	love.window.setTitle('typing RL')
	love.graphics.setBackgroundColor(255, 255, 255)

	love.keyboard.setKeyRepeat(true)

	math.randomseed(os.time())

	loadVars()

	Gamestate.registerEvents()
	Gamestate.switch(title)

end

function loadVars()
	vars = {}
	vars.blackScreenAlpha = 0
	vars.commandInputted = false
	vars.player_current_health = 200
	vars.enemiesKilled = 0
	vars.playerDeath = false
	vars.titleFont = love.graphics.newFont('zig.ttf', 50)
	vars.mainFont = love.graphics.newFont('zig.ttf', 20)
	vars.typingFont = love.graphics.newFont('zig.ttf', 25)
end

function love.resize(w, h)
	WINDOW_HEIGHT = h
	WINDOW_WIDTH = w
end

function love.update(dt)
	Timer.update(dt)
	
	if vars.blackScreenAlpha < 0 then
		vars.blackScreenAlpha = 0
	elseif vars.blackScreenAlpha > 255 then
		vars.blackScreenAlpha = 255
	end
end

function love.draw()

end

function love.keypressed(key)

end

function tick()
	
end

function takeScreenshot(string)
	-- print(string)
	local scrot = love.graphics.newScreenshot()
	if love.filesystem.exists(string .. '-' .. os.date('%m-%d_%H-%M-%S') .. '.png') then
		scrot:encode(string .. '-' .. os.date('%m-%d_%H-%M-%S') .. '-' .. tostring(math.random(1,100)) .. '.png', 'png')
	else
		scrot:encode(string .. '-' .. os.date('%m-%d_%H-%M-%S') .. '.png', 'png')
	end
end

function contains(table, value)
	for i,v in ipairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

function createEnemy(enemy_type)
	local enemy = {}
	enemy.pos = vector(0,0)

	if enemy_type == nil then
		enemy_type = math.random(1,3)
	end
	enemy.enemy_type = enemy_type
	if enemy_type == 1 then
		enemy.name = 'Skeleton'
	elseif enemy_type == 2 then
		enemy.name = 'Slime'
	elseif enemy_type == 3 then
		enemy.name = 'Elemental'
	else
		enemy.name = 'Enemy'
	end

	enemy.color = {255, 255, 255}
	enemy.image = love.graphics.newImage('enemy' .. tostring(enemy_type) .. '.png')
	enemy.image:setFilter("nearest")
	enemy.max_health = 100
	enemy.kind = 'enemy'

	return enemy

end

function drawBlackScreen()
	love.graphics.setColor(000, 000, 000, math.ceil(vars.blackScreenAlpha))
	love.graphics.rectangle('fill', 0, 0,WINDOW_WIDTH, WINDOW_HEIGHT)
end

function switchToBlack(gamestate, enemy, playerDeath)
	local time = 1
	blackScreenAlpha = 0
	Timer.tween(time, vars, {blackScreenAlpha = 255})
	Timer.add(time, function()
		if enemy then
			gamestate:switchWithInfo(enemy, playerDeath)
		else
			Gamestate.switch(gamestate)
		end
		Timer.tween(time, vars, {blackScreenAlpha = 0})
	end)
end