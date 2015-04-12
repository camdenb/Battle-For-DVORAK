overworld = {}

map = {}
overworld.player = {}

function overworld:init()

end

function overworld:enter()
	
	overworld.camera = cam(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, 3)

	takeScreenshot('battle')

	overworld:loadConstants()
	overworld:initEverything()

end

function overworld:leave()

end

function overworld:update()

end

function overworld:draw()
	overworld.camera:attach()
		love.graphics.setColor(255,255,255,100)
		love.graphics.draw(overworld.img_bg,-250,-250)
		map.draw()
		overworld:drawEnemies()
		overworld.player.draw()
		overworld:drawLetters()
	overworld.camera:detach()
end

function overworld:keypressed(key)
	if key == 'h' or key == 'left' then
		overworld.player.move(vector(-1,0))
	elseif key == 'j' or key == 'down' then
		overworld.player.move(vector(0,1))
	elseif key == 'k' or key == 'up' then
		overworld.player.move(vector(0,-1))
	elseif key == 'l' or key == 'right' then
		overworld.player.move(vector(1,0))
	end
	
end


--[[------
FUNCTIONS
------]]--

--[[------
init stuff
------]]--

function overworld:loadConstants()
	map.OFFSET = vector(0,0)
	map.WIDTH = 25
	map.HEIGHT = 25
	map.CELLSIZE = 20

	letterFont = love.graphics.newFont(10)

	enemies = {}

	overworld.img_bg = love.graphics.newImage('bg.png')
	overworld.img_player = love.graphics.newImage('player.png')
	overworld.img_player:setFilter("nearest")
	overworld.img_enemy_2 = love.graphics.newImage('enemy_2.png')
	overworld.img_enemy_2:setFilter("nearest")

	overworld.CURRENT_ENEMY = nil
end

function overworld:initEverything()
	overworld.player.init()
	overworld:spawnEnemy(overworld.player.pos * 7)
end

--[[------
map stuff
------]]--

function map.draw()

	love.graphics.setColor(210, 210, 210)
	love.graphics.setLineWidth(1)

	for x = map.OFFSET.x, map.OFFSET.x + map.WIDTH, 1 do
		for y = map.OFFSET.y, map.OFFSET.y + map.HEIGHT, 1 do
			love.graphics.rectangle('line', x * map.CELLSIZE, y * map.CELLSIZE, map.CELLSIZE, map.CELLSIZE)
		end
	end

end

--[[------
overworld.player stuff
------]]--

function overworld.player.init()
	-- pos is in MAP COORDS not actual coords, ie it's by cell not by pixel
	overworld.player.pos = vector(1,1)

	overworld.camera:lookAt((overworld.player.pos * map.CELLSIZE):unpack())
		
	-- size is in pixels
	overworld.player.size = map.CELLSIZE - 6
end

function overworld.player.draw()
	love.graphics.setColor(255, 255, 255)
	local offset = overworld.player.size / 2 + map.CELLSIZE / 2
	love.graphics.draw(overworld.img_player, (overworld.player.pos.x * map.CELLSIZE) - offset, (overworld.player.pos.y * map.CELLSIZE) - offset)
end

-- direction is a vector
function overworld.player.move(direction)

	overworld:moveEntity(overworld.player, direction)
	
	overworld:nextMovement()

end

function overworld.player.checkCell(location)
	for i,enemy in ipairs(enemies) do
		if enemy.pos == location then
			overworld:triggerBattle(enemy)
		end
	end
end

--[[------
enemy stuff
------]]--

function overworld:nextMovement()

	for i,enemy in ipairs(enemies) do
		if enemy.pos:dist(overworld.player.pos) < 5 then
			moveTowardsPlayer(enemy)
		else
			local moveX, moveY = math.random(-1,1), math.random(-1,1)
			if math.random(0,1) == 1 then
				moveX = 0
			else
				moveY = 0
			end
			overworld:moveEntity(enemy, vector(moveX, moveY))
		end
	end
	overworld.player.checkCell(overworld.player.pos)
	overworld.camera:lookAt((overworld.player.pos * map.CELLSIZE):unpack())
end

function overworld:spawnEnemy(_pos)
	local enemy = {
		pos = _pos, enemy_type = 2, size = map.CELLSIZE - 10
	}
	table.insert(enemies, enemy)
end

function overworld:drawEnemies()
	for i,enemy in ipairs(enemies) do
		love.graphics.setColor(255, 255, 255)
		local offset = (enemy.size / 2 + map.CELLSIZE / 2) * 0
		local img = nil
		if enemy.enemy_type == 2 then
			img = overworld.img_enemy_2
		end
		love.graphics.draw(img, (enemy.pos.x * map.CELLSIZE) - offset, (enemy.pos.y * map.CELLSIZE) - offset)
	end
end

function moveTowardsPlayer(enemy)
	local diffX = overworld.player.pos.x - enemy.pos.x
	local diffY = overworld.player.pos.y - enemy.pos.y
	
	if diffX == diffY then
		-- if math.random(1, 2) == 1 then
		-- 	enemy.pos.x = enemy.pos.x + (math.abs(diffX) / diffX)
		-- else
		-- 	enemy.pos.y = enemy.pos.y + (math.abs(diffY) / diffY)
		-- end
	elseif math.abs(diffX) > math.abs(diffY) then
		enemy.pos.x = enemy.pos.x + (math.abs(diffX) / diffX)
	elseif math.abs(diffY) > math.abs(diffX) then
		enemy.pos.y = enemy.pos.y + (math.abs(diffY) / diffY)
	end

end

--[[------
gui stuff
------]]--

function overworld:drawLetters()
	love.graphics.setFont(letterFont)
	
	--h
	love.graphics.setColor(000, 000, 000, 100)
	love.graphics.print('H', (overworld.player.pos.x - 2) * map.CELLSIZE + 10, (overworld.player.pos.y - 1) * map.CELLSIZE)

	--j
	love.graphics.setColor(000, 000, 000, 100)
	love.graphics.print('J', (overworld.player.pos.x - 1) * map.CELLSIZE + 10, (overworld.player.pos.y) * map.CELLSIZE)

	--k
	love.graphics.setColor(000, 000, 000, 100)
	love.graphics.print('K', (overworld.player.pos.x - 1) * map.CELLSIZE + 10, (overworld.player.pos.y - 2) * map.CELLSIZE)

	--l
	love.graphics.setColor(000, 000, 000, 100)
	love.graphics.print('L', overworld.player.pos.x * map.CELLSIZE + 10, (overworld.player.pos.y - 1) * map.CELLSIZE)
end

--[[------
misc stuff
------]]--

function overworld:triggerBattle(enemy)
	overworld.CURRENT_ENEMY = enemy
	Gamestate.switch(battle)	
end

function overworld:moveEntity(entity, direction)
	local newPos = entity.pos + direction

	newPos.x = math.floor(newPos.x)
	newPos.y = math.floor(newPos.y)

	if newPos.x < 1 then
		newPos.x = 1
	elseif newPos.x > map.WIDTH then
		newPos.x = map.WIDTH
	end
	if newPos.y < 1 then
		newPos.y = 1
	elseif newPos.y > map.HEIGHT then
		newPos.y = map.HEIGHT
	end

	entity.pos = newPos
end