midscreen = {}


function midscreen:init()

end

function midscreen:enter()

	takeScreenshot('midscreen')

	vars.commandInputted = false

	midscreen:loadConstants()
	midscreen:initEverything()


end

function midscreen:leave()

end

function midscreen:update()

end

function midscreen:draw()

	midscreen:drawCongratsMessage()

	inputBar.draw()

	drawBlackScreen()

end

function midscreen:keypressed(key)
	inputBar.processInput(key)
end

function midscreen:switchWithInfo(enemy)
	Gamestate.switch(midscreen)
	midscreen.enemy = enemy
end

--[[------
FUNCTIONS
------]]--

function midscreen:loadConstants()
	inputBar.init()
	if midscreen.enemy == nil then
		midscreen.enemy = createEnemy()
	end

	midscreen.textFont_1 = love.graphics.newFont('zig.ttf', 15)
	midscreen.textFont_2 = love.graphics.newFont('zig.ttf', 20)
	midscreen.textFont_3 = love.graphics.newFont('zig.ttf', 30)

	midscreen.newCoins = 0

end

function midscreen:initEverything()
	midscreen:generateRewards()

	Signals.register('inputBarChanged', function(newWord) midscreen:inputBarChanged(newWord) end)

end

--[[------
text stuff
------]]--

function midscreen:drawCongratsMessage()
	love.graphics.setColor(000, 000, 000)

	midscreen:drawCenteredText('Congratulations!', 40, 3)

	midscreen:drawCenteredText('You killed the ' .. midscreen.enemy.name .. '', 120, 2)
	midscreen:drawCenteredText('and ', 148, 1)
	midscreen:drawCenteredText('You found ' .. midscreen.newCoins .. ' coins!', 170, 2)

	midscreen:drawCenteredText('Type \"explore\" to \nsearch for more enemies', 350, 2)


end

function midscreen:drawCenteredText(text, yPos, size)
	local currentFont = nil
	if size == 1 then
		currentFont = midscreen.textFont_1
	elseif size == 2 then
		currentFont = midscreen.textFont_2
	elseif size == 3 then
		currentFont = midscreen.textFont_3
	else
		currentFont = midscreen.textFont_2
	end
	love.graphics.setFont(currentFont)
	local text_width = currentFont:getWidth(text)
	love.graphics.printf(text, WINDOW_WIDTH / 2 - text_width / 2, yPos, text_width, 'center')
end

--[[------
loot stuff
------]]--

function midscreen:generateRewards()
	midscreen.newCoins = midscreen:getCoinsFound()
end

function midscreen:getCoinsFound()
	return math.random(10, 100)
end

--[[------
exploring stuff
------]]--

function midscreen:inputBarChanged(newWord)
	if not vars.commandInputted then
		if newWord == 'explore' then
			midscreen:explore()
			vars.commandInputted = true
		end
	end
end

function midscreen:explore()
	switchToBlack(battle)
end
