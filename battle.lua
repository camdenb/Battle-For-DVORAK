battle = {}

function battle:init()

end

function battle:enter()

	love.graphics.setBackgroundColor(220, 220, 220)

	battle.camera = cam(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)

	takeScreenshot('battle')

	battle:loadConstants()
	battle:initEverything()

	-- Timer.addPeriodic(5, function()
	-- 	battle:objectHit(battle.player, math.random(50, 100))
	-- end)

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
		battle:drawEnemyPrompt()
		battle:drawEnemyInput()
		battle:drawPlayer()
		battle:drawPlayerPrompt()
		battle:drawPlayerInput()
		battle:drawSlash()
	battle.camera:detach()
	drawBlackScreen()
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
	battle:enemyChanceToType()
end

function battle:switchWithInfo()
	Gamestate.switch(battle)
end

--[[------
FUNCTIONS
------]]--

--[[------
init stuff
------]]--

function battle:loadConstants()

	battle.tickCounter = 0
	battle.tickMax = 20

	if vars.swearMode then
		battle:loadWordsFromFile('swear-words.txt')
	else
		battle:loadWordsFromFile('smaller-words.txt')
	end

	battle.img_player = love.graphics.newImage('player.png')
	battle.img_player:setFilter("nearest")
	battle.img_slash = love.graphics.newImage('hit.png')
	battle.img_slash:setFilter("nearest")
	battle.slashColor = {255, 255, 255, 0}

	sound_type = love.audio.newSource({'tw2.wav'}, 'stream')
	sound_type:setVolume(.3)

	sound_hurt = love.audio.newSource({'hurt.wav'}, 'stream')
	sound_hurt:setVolume(.3)

	battle.health_borderwidth = 2
	battle.health_height = 10

	battle.healthbar_font = love.graphics.newFont('zig.ttf', 10)
	battle.battleFont = love.graphics.newFont('zig.ttf', 30)
	battle.battleFont_enemy = love.graphics.newFont('zig.ttf', 20)

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
	battle.enemyStart = false
	Timer.add(3, function() battle.enemyStart = true end)
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
	love.graphics.draw(battle.img_player, battle.player.pos.x, battle.player.pos.y, 0, 10)
	battle:drawOutlineBoxThing(vector(0, 350), vector(450, 200))

	local health_pos = vector(150, 330)

	battle:drawHealthBar(health_pos, battle.player.current_health, battle.player.max_health, 200, battle.player.name)

end

function battle:determinePlayerStats()
	battle.player.max_health = 200
	battle.player.current_health = vars.player_current_health or battle.player.max_health
end

function battle:initPlayer()
	battle.player = {}
	battle.player.kind = 'player'
	battle.player.name = 'player'
	battle:determinePlayerStats()
	battle.player.color = {255, 255, 255}
	battle.player.isDead = false
	battle.player.pos = vector(0, 200)
end

--[[------
enemy stuff
------]]--

function battle:drawEnemy()
	local health_pos = vector(100, 60)
	love.graphics.setColor(battle.enemy.color)
	love.graphics.draw(battle.enemy.image, battle.enemy.pos.x, battle.enemy.pos.y, 0, 7)
	battle:drawOutlineBoxThing(vector(182, 120), vector(450, 100))
	battle:drawHealthBar(health_pos, battle.enemy.current_health, battle.enemy.max_health, 200, battle.enemy.name)

end

function battle:determineEnemyStats()
	battle.enemy.current_health = battle.enemy.max_health
end

function battle:initEnemy()
	battle.enemy = createEnemy()
	battle:determineEnemyStats()
	battle.enemy.pos = vector(320, 0)

	battle.enemy.current_word = ''
	battle.enemy.answer_word = battle:enemyChooseWord()
	battle.enemy.answer_word_pos_PERMANENT = vector(200, 140)
	battle.enemy.answer_word_pos = battle.enemy.answer_word_pos_PERMANENT:clone()
	battle.enemy.current_word_pos_PERMANENT = vector(200, 165)
	battle.enemy.current_word_pos = battle.enemy.current_word_pos_PERMANENT:clone()
	battle.enemy.wordIsComplete = false
	battle.enemy.isDead = false
end

function battle:enemyChooseWord()
	return battle.words[math.random(1, #battle.words)]
end

function battle:enemyChanceToType()
	if math.random(1,2) == 1 and not battle.enemy.isDead and not battle.player.isDead and battle.enemyStart then
		battle:enemyTypeNextLetter()
		battle:enemyCheckWord()
	end
end

function battle:enemyTypeNextLetter()
	battle.enemy.nextLetter = battle.enemy.answer_word:sub(#battle.enemy.current_word + 1, #battle.enemy.current_word + 1)
	battle.enemy.current_word = battle.enemy.current_word .. battle.enemy.nextLetter
end

function battle:enemyCheckWord()
	if battle.enemy.answer_word == battle.enemy.current_word and battle.enemy.wordIsComplete == false then
		battle:enemyWordIsCorrect()
	end
end

function battle:resetEnemyWordPos()
	battle.enemy.answer_word_pos = battle.enemy.answer_word_pos_PERMANENT:clone()
	battle.enemy.current_word_pos = battle.enemy.current_word_pos_PERMANENT:clone()
end

function battle:enemyWordIsCorrect()
	battle.enemy.wordIsComplete = true
	Timer.tween(.3, battle.enemy.current_word_pos, battle.enemy.answer_word_pos, 'in-back')
	Timer.add(.3, function()
		battle:objectHit(battle.player, #battle.enemy.current_word * 3)
	end)
	battle.wordTimer.add(1, function() 
		battle:enemyNewWord()
	end)
end

function battle:enemyNewWord()
	battle:resetEnemyWordPos()
	battle.enemy.answer_word = battle:enemyChooseWord()
	battle.enemy.current_word = ''
	battle.enemy.wordIsComplete = false
end

function battle:drawEnemyInput()
	love.graphics.setColor(000, 000, 000)
	love.graphics.setFont(battle.battleFont_enemy)

	local size = battle.battleFont_enemy:getWidth(' ')
	local height = battle.battleFont_enemy:getHeight()
	for x = 1, #battle.enemy.current_word, 1 do
		local letter = string.sub(battle.enemy.current_word, x, x)
		love.graphics.print(letter, battle.enemy.current_word_pos.x + (x - 1) * size, battle.enemy.current_word_pos.y)
	end
end

function battle:drawEnemyPrompt()
	love.graphics.setColor(000, 000, 000)
	love.graphics.setFont(battle.battleFont_enemy)

	local size = battle.battleFont_enemy:getWidth(' ')
	local height = battle.battleFont_enemy:getHeight()

	for x = 1, #battle.enemy.answer_word, 1 do
		local letter = string.sub(battle.enemy.answer_word, x, x)
		love.graphics.print(letter, battle.enemy.answer_word_pos.x + (x - 1) * size, battle.enemy.answer_word_pos.y)
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
	love.graphics.setFont(battle.healthbar_font)
	love.graphics.print(name, health_pos.x, health_pos.y - 12)
	local healthStr = math.ceil(tostring(current_health)) .. '/' .. tostring(max_health)
	love.graphics.print(healthStr, health_pos.x + actual_width - battle.healthbar_font:getWidth(healthStr), health_pos.y - 12)
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
		local time = math.abs((object.current_health - final) / (num * 3))
		Timer.tween(time, object, {current_health = final})
		if final == 0 then
			if object.kind == 'enemy' and not battle.enemy.isDead then
				Timer.add(time, function() battle:enemyKilled() end)
			elseif object.kind == 'player' and not battle.player.isDead then
				Timer.add(time, function() battle:playerKilled() end)
			end
		end
	else
		object.current_health = final
	end
	return (object.current_health - num) <= 0
end

--[[------
animation stuff
------]]--

function battle:objectHit(object, damage)
	battle:animateHit(object)
	Timer.add(0.6, function()
		battle:addToHealth(object, -damage, true)
	end)
	return object.current_health - damage <= 0
end

function battle:animateHit(object)
	local t = 0
	sound_hurt:play()
	-- battle:animateSlash()
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

function battle:animateSlash()
	Timer.tween(0.01, battle, {slashColor = {255, 255, 255, 255}}, 'linear')
	Timer.add(0.2, function()
		Timer.tween(0.2, battle, {slashColor = {255, 255, 255, 0}}, 'in-quart')
	end)
end

function battle:drawSlash()
	love.graphics.setColor(battle.slashColor)
	love.graphics.draw(battle.img_slash, battle.enemy.pos.x, battle.enemy.pos.y, 0, 7)
end

--[[------
typing stuff
------]]--

function battle:loadWordsFromFile(file)
	battle.words = {}
	for line in love.filesystem.lines(file) do
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
	love.graphics.setFont(battle.battleFont)
	-- love.graphics.print(battle.current_word, 100, 400)

	local size = battle.battleFont:getWidth(' ')
	local height = battle.battleFont:getHeight()
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
	love.graphics.setFont(battle.battleFont)

	local size = battle.battleFont:getWidth(' ')
	local height = battle.battleFont:getHeight()
	for x = 1, #battle.answer_word, 1 do
		local letter = string.sub(battle.answer_word, x, x)
		love.graphics.print(letter, battle.answer_word_pos.x + (x - 1) * size, battle.answer_word_pos.y)
	end
end

function battle:processKeyPressed(key)
	if not battle.enemy.isDead then
		if contains(battle.letters, key) then
			battle:processLetterTyped(key)
			battle:ascertainCorrectness()
		elseif key == 'backspace' then
			battle:processBackspace()
			battle:ascertainCorrectness()
		end
	end
end

function battle:processLetterTyped(key)
	if battle.wordIsComplete == false then
		battle.current_word = battle.current_word .. key

		local typingSound = sound_type:play()
	    typingSound:setPitch(.5 + math.random() * .3) 
	end

end

function battle:ascertainCorrectness()
	if battle.current_word:sub(1, #battle.current_word) == battle.answer_word:sub(1, #battle.current_word) then
		battle.word_correct_so_far = true
		battle:checkWord()
	else
		battle.word_correct_so_far = false
	end
end

function battle:checkWord()
	if battle.current_word == battle.answer_word and not battle.wordIsComplete then
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
		battle:objectHit(battle.enemy, #battle.current_word * 3)
	end)
	battle.wordTimer.add(1, function() battle:newWord() end)
end

function battle:processBackspace()
	battle.current_word = string.sub(battle.current_word, 1, #battle.current_word - 1)
end

function battle:enemyKilled()
	battle.enemy.isDead = true
	vars.enemiesKilled = vars.enemiesKilled + 1
	vars.player_current_health = battle.player.current_health
	Timer.tween(0.6, battle.enemy.pos, {y = 1000}, 'in-back')
	Timer.add(1, function()
		switchToBlack(midscreen, battle.enemy)
	end)
end

function battle:playerKilled()
	battle.player.isDead = true
	vars.playerDeath = true
	Timer.tween(0.6, battle.player.pos, {y = 1000}, 'in-back')
	Timer.add(1, function()
		switchToBlack(midscreen)
	end)
end