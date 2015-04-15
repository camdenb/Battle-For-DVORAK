title = {}

function title:init()
	
end

function title:enter()
	love.graphics.setBackgroundColor(220, 220, 220)
	-- Timer.add(2, function() Gamestate.switch(game) end)

	title.currentWord = ''

	love.audio.setVolume(.3)

	title.titlePos = vector(0, -200)

	title.commandCorrect = false
	title.letters = {
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', ' '
	}	

	title.titleFloatTime = 2.5
	title.floatCounter = 0
	Timer.addPeriodic(title.titleFloatTime, function()
		if Gamestate.current() == title then
			title:tweenTitle()
		end
	end)

end

function title:update(dt)

	Timer.update(dt)

end

function title:draw()
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(vars.titleFont)
	love.graphics.printf('BATTLE FOR DVORAK', WINDOW_WIDTH / 2, title.titlePos.y, 0, 'center')
	love.graphics.setFont(vars.mainFont)
	local word = 'a game by'
	love.graphics.printf(word, WINDOW_WIDTH / 2 - vars.mainFont:getWidth(word) / 2, 250, vars.mainFont:getWidth(word), 'center')
	local word = 'camdenb'
	love.graphics.printf(word, WINDOW_WIDTH / 2 - vars.mainFont:getWidth(word) / 2, 270, vars.mainFont:getWidth(word), 'center')
	local word = '(bearchinski)'
	love.graphics.printf(word, WINDOW_WIDTH / 2 - vars.mainFont:getWidth(word) / 2, 290, vars.mainFont:getWidth(word), 'center')
	-- love.graphics.rectangle('fill', WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, 10, 10)
	love.graphics.setFont(vars.mainFont)
	local word = 'Type \"play\" to get started!'
	love.graphics.printf(word, WINDOW_WIDTH / 2 - vars.mainFont:getWidth(word) / 2, 400, vars.mainFont:getWidth(word), 'center')

	if title.commandCorrect then
		love.graphics.setColor(000, 200, 000)
	end
	love.graphics.setFont(vars.typingFont)
	love.graphics.print(title.currentWord, WINDOW_WIDTH / 2 - vars.mainFont:getWidth(word) / 2, WINDOW_HEIGHT - 60)
	drawBlackScreen()
end

function title:keypressed(key)
	if key == 'backspace' then
		title.currentWord = string.sub(title.currentWord, 1, #title.currentWord - 1)
		if #title.currentWord > 0 then
			title:checkWord()
		end
	elseif contains(title.letters, key) then

		title.currentWord = title.currentWord .. key
		title:checkWord()
	end
end

function title:checkWord()
	if title.currentWord == 'play' then
		title.commandCorrect = true
		Timer.add(2, function() switchToBlack(battle) end)
	elseif title.currentWord == 'fuck' and not vars.swearMode then
		title.commandCorrect = true
		vars.swearMode = true
		Timer.add(2, function()
			title.commandCorrect = false
			title.currentWord = ''
		end)
	elseif title.currentWord == 'sorry' and vars.swearMode then
		title.commandCorrect = true
		vars.swearMode = false
		Timer.add(2, function()
			title.commandCorrect = false
			title.currentWord = ''
		end)
	end
end

function title:clearCurrentWord()
	title.currentWord = ''
end

function title:tweenTitle()
	local newPos = 0
	if title.floatCounter == 0 then
		newPos = 70
	else
		newPos = 48
	end
	Timer.tween(title.titleFloatTime, title.titlePos, {y = newPos}, 'in-out-sine')
	title.floatCounter = (title.floatCounter + 1) % 2
end	