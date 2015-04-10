battle = {}

function battle:init()

end

function battle:enter()

	battle.camera = cam(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)

	takeScreenshot('battle')

	battle:loadConstants()
	battle:initEverything()

end

function battle:leave()

end

function battle:update()
	battle:updateTick()


end

function battle:draw()
	battle.camera:attach()
		battle:drawEnemy()
		battle:drawPlayer()
		battle:drawPlayerInput()
		battle:drawPlayerPrompt()
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

	img_enemy_1 = love.graphics.newImage('enemy_1.png')
	img_enemy_2 = love.graphics.newImage('enemy_2.png')
	img_enemy_2:setFilter("nearest")
	img_player = love.graphics.newImage('player.png')
	img_player:setFilter("nearest")

	battle.health_borderwidth = 2
	battle.health_height = 10

	healthbar_font = love.graphics.newFont('zig.ttf', 10)
	battleFont = love.graphics.newFont('zig.ttf', 30)

	battle.letters = {
		'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', ' '
	}	
	battle.current_word = ''
	battle.answer_word = 'catastrophe'
end

function battle:initEverything()
	battle:initEnemy()
	battle:initPlayer()
end

--[[------
player stuff
------]]--

function battle:drawPlayer()

	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(img_player, 0, 200, 0, 10)
	battle:drawOutlineBoxThing(vector(0, 350), vector(450, 200))

	local health_pos = vector(150, 330)

	love.graphics.setColor(000, 000, 000)
	love.graphics.setFont(healthbar_font)
	love.graphics.print('Player', health_pos.x, health_pos.y - 12)
	love.graphics.print(tostring(battle.player.current_health) .. '/' .. tostring(battle.player.max_health), health_pos.x + 60, health_pos.y - 12)

	battle:drawHealthBar(health_pos, battle.player.current_health, battle.player.max_health)


end

function battle:determinePlayerStats()
	battle.player.max_health = 100
	battle.player.current_health = battle.player.max_health
end

function battle:initPlayer()
	battle.player = {}
	battle:determinePlayerStats()
end

--[[------
enemy stuff
------]]--

function battle:drawEnemy()
	local health_pos = vector(180, 100)
	if battle.enemy.enemy_type == 1 then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(img_enemy_1, 300, 10)
		love.graphics.setColor(000, 000, 000)
		love.graphics.setFont(healthbar_font)
		love.graphics.print('Skeleton', health_pos.x, health_pos.y - 12)
	elseif battle.enemy.enemy_type == 2 then
		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(img_enemy_2, 320, -35, 0, 10)
		love.graphics.setColor(000, 000, 000)
		love.graphics.setFont(healthbar_font)
		love.graphics.print('Slime', health_pos.x, health_pos.y - 12)
	end
	love.graphics.print(tostring(battle.enemy.current_health) .. '/' .. tostring(battle.enemy.max_health), health_pos.x + 60, health_pos.y - 12)
	battle:drawOutlineBoxThing(vector(182, 120), vector(450, 100))
	battle:drawHealthBar(health_pos, battle.enemy.current_health, battle.enemy.max_health)

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
end

--[[------
enemy + player universal gui stuff
------]]--

function battle:drawHealthBar(health_pos, current_health, max_health)
	love.graphics.setColor(000, 000, 000)
	love.graphics.rectangle('fill', health_pos.x, health_pos.y, max_health, battle.health_height)
	love.graphics.setColor(255, 000, 000)
	if current_health < battle.health_borderwidth * 2 then
		current_health = battle.health_borderwidth * 2
	end
	love.graphics.rectangle('fill', health_pos.x + battle.health_borderwidth, health_pos.y + battle.health_borderwidth, current_health - battle.health_borderwidth * 2, battle.health_height - battle.health_borderwidth * 2)
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

--[[------
typing stuff
------]]--

function battle:drawPlayerInput()
	love.graphics.setColor(000, 000, 000)
	love.graphics.setFont(battleFont)
	-- love.graphics.print(battle.current_word, 100, 400)

	local word_pos = vector(15, 410)
	local size = battleFont:getWidth(' ')
	local height = battleFont:getHeight()
	for x = 1, #battle.current_word, 1 do
		local letter = string.sub(battle.current_word, x, x)
		love.graphics.print(letter, word_pos.x + (x - 1) * size, word_pos.y)
	end
	if battle.tickCounter % 60 < 30 then
		love.graphics.rectangle('fill', word_pos.x + #battle.current_word * size + 2, word_pos.y, size, height - 5)
	end
end

function battle:drawPlayerPrompt()
	love.graphics.setColor(000, 000, 000)
	love.graphics.setFont(battleFont)

	local word_pos = vector(15, 370)
	local size = battleFont:getWidth(' ')
	local height = battleFont:getHeight()
	for x = 1, #battle.answer_word, 1 do
		local letter = string.sub(battle.answer_word, x, x)
		love.graphics.print(letter, word_pos.x + (x - 1) * size, word_pos.y)
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
