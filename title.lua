title = {}

function title:init()
	
end

function title:enter()
	love.graphics.setBackgroundColor(220, 220, 220)
	-- Timer.add(2, function() Gamestate.switch(game) end)

	title.currentWord = ''

	love.audio.setVolume(.3)

	title.commandCorrect = false
	title.letters = {
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', ' '
	}	

end

function title:update(dt)

	Timer.update(dt)

end

function title:draw()
	love.graphics.setColor(0, 0, 0)
	love.graphics.setFont(vars.titleFont)
	love.graphics.printf('NAME OF GAME', WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2 - 200, 0, 'center')
	-- love.graphics.rectangle('fill', WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, 10, 10)
	love.graphics.setFont(vars.mainFont)
	love.graphics.print('Type \'play\' to get started!', 10, WINDOW_HEIGHT - 80)

	if title.commandCorrect then
		love.graphics.setColor(000, 200, 000)
	end
	love.graphics.setFont(vars.typingFont)
	love.graphics.print(title.currentWord, 10, WINDOW_HEIGHT - 40)
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
	end
end

function title:clearCurrentWord()
	title.currentWord = ''
end