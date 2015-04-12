inputBar = {}

function inputBar.init()
	inputBar.width = 400
	inputBar.height = 70
	inputBar.pos = vector(WINDOW_WIDTH / 2 - inputBar.width / 2, WINDOW_HEIGHT - inputBar.height)
	inputBar.word = ''
	inputBar.font = love.graphics.newFont('zig.ttf', 25)
	inputBar.letters = {
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', ' '
	}	
	inputBar.hidden = false

end

function inputBar.draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle('fill', inputBar.pos.x, inputBar.pos.y, inputBar.width, inputBar.height)

	love.graphics.setColor(200, 200, 200)
	love.graphics.rectangle('line', inputBar.pos.x, inputBar.pos.y, inputBar.width, inputBar.height)

	love.graphics.setColor(100, 100, 100)
	love.graphics.setFont(inputBar.font)
	love.graphics.printf(inputBar.word, inputBar.pos.x, inputBar.pos.y + inputBar.font:getHeight(' '), inputBar.width, 'center')
end

function inputBar.processInput(key)
	if contains(inputBar.letters, key) then
		local newStr = inputBar.word .. key
		if inputBar.font:getWidth(newStr) < inputBar.width then
			inputBar.word = newStr
		end
		Signals.emit('inputBarChanged', newStr)
	elseif key == 'backspace' then
		inputBar.backspace()
	end
end

function inputBar.backspace()
	local newStr = inputBar.word:sub(1, #inputBar.word - 1)
	inputBar.word = newStr
end

function inputBar.reset()
	inputBar.word = ''
end

function inputBar.hide(hide)
	if hide then
		if not inputBar.hidden then
			inputBar.hidden = true
			Timer.tween(0.5, inputBar.pos, {y = inputBar.pos.y + (inputBar.height + 10)}, 'in-quart')
		end
	else
		if inputBar.hidden then
			inputBar.hidden = false
			Timer.tween(0.5, inputBar.pos, {y = inputBar.pos.y - (inputBar.height + 10)}, 'in-quart')
		end
	end

end
