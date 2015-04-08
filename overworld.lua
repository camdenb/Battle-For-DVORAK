overworld = {}

map = {}
player = {}

function overworld:init()
	camera = cam(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2)
end

function overworld:enter()

	

	overworld:loadConstants()
	overworld:initEverything()

end

function overworld:leave()

end

function overworld:update()

end

function overworld:draw()
	camera:attach()
		love.graphics.setColor(255,255,255,100)
		love.graphics.draw(img_bg,-250,-250)
		-- map.draw()
		overworld:drawEnemies()
		player.draw()
		overworld:drawLetters()
	camera:detach()
end

function overworld:keypressed(key)
	if key == 'h' or key == 'left' then
		player.move(vector(-1,0))
	elseif key == 'j' or key == 'down' then
		player.move(vector(0,1))
	elseif key == 'k' or key == 'up' then
		player.move(vector(0,-1))
	elseif key == 'l' or key == 'right' then
		player.move(vector(1,0))
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

	img_bg = love.graphics.newImage('bg.png')
end

function overworld:initEverything()
	player.init()
	overworld:spawnEnemy(vector(15,25))
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
player stuff
------]]--

function player.init()
	-- pos is in MAP COORDS not actual coords, ie it's by cell not by pixel
	player.pos = vector(1,1)

	camera:lookAt((player.pos * map.CELLSIZE):unpack())
		
	-- size is in pixels
	player.size = map.CELLSIZE - 6
end

function player.draw()
	love.graphics.setColor(000, 000, 255)
	local offset = player.size / 2 + map.CELLSIZE / 2
	love.graphics.rectangle('fill', (player.pos.x * map.CELLSIZE) - offset, (player.pos.y * map.CELLSIZE) - offset, player.size, player.size)
end

-- direction is a vector
function player.move(direction)

	overworld:moveEntity(player, direction)
	
	overworld:nextMovement()

end

function player.checkCell(location)
	for i,enemy in ipairs(enemies) do
		if enemy.pos == location then
			overworld:triggerBattle()
		end
	end
end

--[[------
enemy stuff
------]]--

function overworld:nextMovement()

	for i,enemy in ipairs(enemies) do
		if enemy.pos:dist(player.pos) < 5 then
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
	player.checkCell(player.pos)
	camera:lookAt((player.pos * map.CELLSIZE):unpack())
end

function overworld:spawnEnemy(_pos)
	local enemy = {
		pos = _pos, enemy_type = 1, size = map.CELLSIZE - 10
	}
	table.insert(enemies, enemy)
end

function overworld:drawEnemies()
	for i,enemy in ipairs(enemies) do
		love.graphics.setColor(100, 100, 100)
		local offset = enemy.size / 2 + map.CELLSIZE / 2
		love.graphics.rectangle('fill', (enemy.pos.x * map.CELLSIZE) - offset, (enemy.pos.y * map.CELLSIZE) - offset, enemy.size, enemy.size)
	end
end

function moveTowardsPlayer(enemy)
	local diffX = player.pos.x - enemy.pos.x
	local diffY = player.pos.y - enemy.pos.y
	
	if diffX == diffY then
		if math.random(1, 2) == 1 then
			enemy.pos.x = enemy.pos.x + (math.abs(diffX) / diffX)
		else
			enemy.pos.y = enemy.pos.y + (math.abs(diffY) / diffY)
		end
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
	love.graphics.print('H', (player.pos.x - 2) * map.CELLSIZE + 10, (player.pos.y - 1) * map.CELLSIZE)

	--j
	love.graphics.setColor(000, 000, 000, 100)
	love.graphics.print('J', (player.pos.x - 1) * map.CELLSIZE + 10, (player.pos.y) * map.CELLSIZE)

	--k
	love.graphics.setColor(000, 000, 000, 100)
	love.graphics.print('K', (player.pos.x - 1) * map.CELLSIZE + 10, (player.pos.y - 2) * map.CELLSIZE)

	--l
	love.graphics.setColor(000, 000, 000, 100)
	love.graphics.print('L', player.pos.x * map.CELLSIZE + 10, (player.pos.y - 1) * map.CELLSIZE)
end

--[[------
misc stuff
------]]--

function overworld:triggerBattle()
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