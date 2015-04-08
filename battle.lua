battle = {}

function battle:init()

end

function battle:enter()

	-- camera = cam:new(WINDOW_WIDTH / 2, WINDOW_HEIGHT / 2, .5)

	battle:loadConstants()
	battle:initEverything()

end

function battle:leave()

end

function battle:update()

end

function battle:draw()
	-- camera:attach()
		love.graphics.print('battle!!', 0, 0)
	-- camera:detach()
end

function battle:keypressed(key)

end

--[[------
FUNCTIONS
------]]--

--[[------
init stuff
------]]--

function battle:loadConstants()
	
end

function battle:initEverything()
	
end