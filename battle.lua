battle = {}

function battle:init()

end

function battle:enter()

	battle.camera = cam(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)

	math.randomseed(os.time())

	takeScreenshot('battle')

	battle:loadConstants()
	battle:initEverything()

	Timer.addPeriodic(5, function()
		battle:objectHit(battle.player, math.random(50, 100))
	end)

end

function battle:leave()

end

function battle:update(dt)
	battle:updateTick()
	battle.wordTimer.update(dt)
end

function battle:draw()
	battle.camera:attach()
		battle:drawEnemy()
		battle:drawPlayer()
		battle:drawPlayerPrompt()
		battle:drawPlayerInput()
	battle.camera:detach()
end

function battle:keypressed(key)
	battle:processKeyPressed(key)
end

function battle:updateTick()
	battle.tickCounter = battle.tickCounter + 1
	if battle.tickCounter >= battle.tickMax then
		battle:tick()
		battle.tickCounter = 0
	end
end

function battle:tick()

end

--[[------
FUNCTIONS
------]]--

--[[------
init stuff
------]]--

function battle:loadConstants()
	battle.tickCounter = 0
	battle.tickMax = 60

	battle:loadWordsFromFile()

	img_enemy_1 = love.graphics.newImage('enemy_1.png')
	img_enemy_2 = love.graphics.newImage('enemy_2.png')
	img_enemy_2:setFilter("nearest")
	img_player = love.graphics.newImage('player.png')
	img_player:setFilter("nearest")

	sound_type = love.audio.newSource({'tw2.wav'}, 'stream')
	sound_type:setVolume(.4)

	sound_hurt = love.audio.newSource({'hurt.wav'}, 'stream')
	sound_hurt:setVolume(.4)

	battle.health_borderwidth = 2
	battle.health_height = 10

	healthbar_font = love.graphics.newFont('zig.ttf', 10)
	battleFont = love.graphics.newFont('zig.ttf', 30)

	battle.letters = {
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', ' '
	}	
	battle.current_word = ''
	battle.answer_word = battle.words[math.random(1, #battle.words)]
	battle.wordIsComplete = false
	battle.word_correct_so_far = false --yes I know it's a crappy var name
	battle.answer_word_pos_PERMANENT = vector(15, 370)
	battle.answer_word_pos = battle.answer_word_pos_PERMANENT:clone()
	battle.current_word_pos_PERMANENT = vector(15, 410)
	battle.current_word_pos = battle.current_word_pos_PERMANENT:clone()

	battle.wordTimer = Timer.new()
	battle.enemy_pos = vector(100,100)
end

function battle:initEverything()
	battle:initEnemy()
	battle:initPlayer()
end

--[[------
player stuff
------]]--

function battle:drawPlayer()

	love.graphics.setColor(battle.player.color)
	love.graphics.draw(img_player, 0, 200, 0, 10)
	battle:drawOutlineBoxThing(vector(0, 350), vector(450, 200))

	local health_pos = vector(150, 330)

	battle:drawHealthBar(health_pos, battle.player.current_health, battle.player.max_health, 200, 'Player')


end

function battle:determinePlayerStats()
	battle.player.max_health = 200
	battle.player.current_health = battle.player.max_health
end

function battle:initPlayer()
	battle.player = {}
	battle:determinePlayerStats()
	battle.player.color = {255, 255, 255}
end

--[[------
enemy stuff
------]]--

function battle:drawEnemy()
	local health_pos = vector(180, 100)
	love.graphics.setColor(battle.enemy.color)
	if battle.enemy.enemy_type == 1 then
		love.graphics.draw(img_enemy_1, battle.enemy_pos.x, battle.enemy_pos.y)
	elseif battle.enemy.enemy_type == 2 then
		love.graphics.draw(img_enemy_2, battle.enemy_pos.x, battle.enemy_pos.y, 0, 10)
	end
	battle:drawOutlineBoxThing(vector(182, 120), vector(450, 100))
	battle:drawHealthBar(health_pos, battle.enemy.current_health, battle.enemy.max_health, 100, battle.enemy.name)

end

function battle:determineEnemyStats()
	if battle.enemy.enemy_type == 1 then
		battle.enemy.max_health = 100
	elseif battle.enemy.enemy_type == 2 then
		battle.enemy.max_health = 100
	end
	battle.enemy.current_health = battle.enemy.max_health
end

function battle:initEnemy()
	battle.enemy = overworld.CURRENT_ENEMY or {enemy_type = 2}
	battle:determineEnemyStats()
	if battle.enemy.enemy_type == 1 then
		battle.enemy_pos = vector(320, -35)
		battle.enemy.name = 'Skeleton'
	elseif battle.enemy.enemy_type == 2 then
		battle.enemy_pos = vector(320, -35)
		battle.enemy.color = {255, 255, 255}
		battle.enemy.name = 'Slime'
	end
end

--[[------
enemy + player universal gui stuff
------]]--

function battle:drawHealthBar(health_pos, current_health, max_health, actual_width, name)
	local actual_width = actual_width or 100
	love.graphics.setColor(000, 000, 000)
	love.graphics.rectangle('fill', health_pos.x, health_pos.y, actual_width, battle.health_height)

	local hacky_mult = 1 -- :(  this makes me sad... but I need this to fix display glitch when cur health < 0
	if (current_health / max_health) * actual_width < battle.health_borderwidth * 2 then
		hacky_mult = 0
	end

	love.graphics.setColor(255, 000, 000)
	love.graphics.rectangle('fill', health_pos.x + battle.health_borderwidth, health_pos.y + battle.health_borderwidth, ((current_health / max_health) * actual_width - battle.health_borderwidth * 2) * hacky_mult, battle.health_height - battle.health_borderwidth * 2)

	--name
	love.graphics.setColor(000, 000, 000)
	love.graphics.setFont(healthbar_font)
	love.graphics.print(name, health_pos.x, health_pos.y - 12)
	love.graphics.print(math.ceil(tostring(current_health)) .. '/' .. tostring(max_health), health_pos.x + 60, health_pos.y - 12)
end

function battle:drawOutlineBoxThing(pos, size)
	love.graphics.setColor(100, 100, 100)
	local line_width = 4

	if pos.y - line_width / 2 < 0 then
		pos.y = line_width / 2
	end

	if pos.y + size.y > WINDOW_HEIGHT then
		size.y = WINDOW_HEIGHT - pos.y - line_width / 2
	end

	if pos.x - line_width / 2 < 0 then
		pos.x = line_width / 2
	end

	if pos.x + size.x > WINDOW_WIDTH then
		size.x = WINDOW_WIDTH - pos.x - line_width / 2
	end

	love.graphics.setLineWidth(line_width)
	love.graphics.rectangle('line', pos.x, pos.y, size.x, size.y)
	love.graphics.setColor(255, 246, 224)
	love.graphics.rectangle('fill', pos.x + line_width / 2, pos.y + line_width / 2, size.x - line_width, size.y - line_width)

end

function battle:addToHealth(object, num, animate)
	--num can be pos or neg
	local final = object.current_health + num
	if object.current_health + num > object.max_health then
		final = object.max_health
	elseif object.current_health + num <= 0 then
		final = 0
	end
	if animate then
		Timer.tween(1, object, {current_health = final})
	else
		object.current_health = final
	end
end

--[[------
animation stuff
------]]--

function battle:objectHit(object, damage)
	battle:animateHit(object)
	Timer.add(0.6, function()
		battle:addToHealth(object, -damage, true)
	end)
end

function battle:animateHit(object)
	local t = 0
	sound_hurt:play()
	Timer.do_for(0.5, function(dt)
	    t = t + dt
	    if (t % .2) < .1 then
	    	object.color[4] = 0
	    else
	    	object.color[4] = 255
	    end
	end, function()
	    object.color[4] = 255
	end)
end

--[[------
typing stuff
------]]--

function battle:loadWordsFromFile()
	battle.words = {}
	for line in love.filesystem.lines('words.txt') do
		table.insert(battle.words, tostring(line))
	end
end

function battle:resetPlayerWordPos()
	battle.answer_word_pos = battle.answer_word_pos_PERMANENT:clone()
	battle.current_word_pos = battle.current_word_pos_PERMANENT:clone()
end

function battle:drawPlayerInput()
	if #battle.current_word == 0 then
		love.graphics.setColor(000, 000, 000)
	elseif battle.word_correct_so_far or battle.wordIsComplete then
		love.graphics.setColor(000, 200, 000)
	else
		love.graphics.setColor(255, 000, 000)
	end
	love.graphics.setFont(battleFont)
	-- love.graphics.print(battle.current_word, 100, 400)

	local size = battleFont:getWidth(' ')
	local height = battleFont:getHeight()
	for x = 1, #battle.current_word, 1 do
		local letter = string.sub(battle.current_word, x, x)
		love.graphics.print(letter, battle.current_word_pos.x + (x - 1) * size, battle.current_word_pos.y)
	end
	if not battle.wordIsComplete and battle.tickCounter % 30 < 15 then
		love.graphics.rectangle('fill', battle.current_word_pos.x + #battle.current_word * size, battle.current_word_pos.y, size, height - 5)
	end
end

function battle:drawPlayerPrompt()
	love.graphics.setColor(000, 000, 000)
	love.graphics.setFont(battleFont)

	local size = battleFont:getWidth(' ')
	local height = battleFont:getHeight()
	for x = 1, #battle.answer_word, 1 do
		local letter = string.sub(battle.answer_word, x, x)
		love.graphics.print(letter, battle.answer_word_pos.x + (x - 1) * size, battle.answer_word_pos.y)
	end
end

function battle:processKeyPressed(key)
	if contains(battle.letters, key) then
		battle:processLetterTyped(key)
	elseif key == 'backspace' then
		battle:processBackspace()
	end
end

function battle:processLetterTyped(key)
	battle.current_word = battle.current_word .. key

	local typingSound = sound_type:play()                       -- creates a new instance
    typingSound:setPitch(.5 + math.random() * .3) 

	if battle.current_word:sub(1, #battle.current_word) == battle.answer_word:sub(1, #battle.current_word) then
		battle.word_correct_so_far = true
		battle:checkWord()
	else
		battle.word_correct_so_far = false
	end
end

function battle:checkWord()
	if battle.current_word == battle.answer_word then
		battle:wordIsCorrect()
	end
end

function battle:selectNewAnswerWord()
	battle.answer_word = battle.words[math.random(1, #battle.words)]
end

function battle:newWord()
	battle:resetPlayerWordPos()
	battle:selectNewAnswerWord()
	battle.current_word = ''
	battle.wordIsComplete = false
end

function battle:wordIsCorrect()

	battle.wordIsComplete = true
	battle.word_correct_so_far = false
	Timer.tween(.3, battle.current_word_pos, battle.answer_word_pos, 'in-back')
	Timer.add(.3, function()
		battle:objectHit(battle.enemy, math.random(10, 20))
	end)
	battle.wordTimer.add(1, function() battle:newWord() end)
end

function battle:processBackspace()
	battle.current_word = string.sub(battle.current_word, 1, #battle.current_word - 1)
end

function contains(table, value)
	for i,v in ipairs(table) do
		if v == value then
			return true
		end
	end
	return false
end

