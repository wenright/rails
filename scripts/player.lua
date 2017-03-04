local Player = Class {}

function Player:init()
	self.w, self.h = 32, 48

	self.x = love.graphics.getWidth() / 2 - self.w / 2
	self.y = (love.graphics.getHeight() * 3) / 4
end

function Player:update(dt)
	-- TODO only calculate if needing to take curve
	self.x = self.rail:getX()
end

function Player:draw()
	love.graphics.setColor(Color[2])
	love.graphics.rectangle('line', self.x, self.y, self.w, self.h, 2)
	love.graphics.rectangle('fill', self.x, self.y, self.w, self.h, 2)
end

function Player:setRail(rail)
	assert(rail, 'Tried to set nil rail')
	self.rail = rail

	if self.rail.type == 'deadend' then
		-- Game Over!
		error('Oh now!')
	end
end

-- Recursively check if there is a route from the current rail to a head
function Player:hasPath()
	assert(self.rail, 'Player is not currently on a rail')

	local pathHead = nil

	local function checkPath(rail)
		if rail == nil then return false end

		if rail.head then
			pathHead = rail
			return rail.type ~= 'deadend'
		end

		if rail.type == 'branch' then
			return checkPath(rail.nextRailBranch) or checkPath(rail.nextRail)
		else
			return checkPath(rail.nextRail)
		end
	end

	return checkPath(self.rail), pathHead
end

function Player:switchRails()
	-- Find the next branch type rail, flip its switch
	local function findNextBranch(rail)
		if rail == nil then
			return nil
		end

		if rail.type == 'branch' then
			return rail
		end

		return findNextBranch(rail.nextRail)
	end

	local nextBranch = findNextBranch(self.rail.nextRail)

	if nextBranch then
		nextBranch:switch()
	else
		print('No branch rails ahead')
	end
end

function love.mousepressed(x, y, button, isTouch)
	Game.player:switchRails()
end

return Player