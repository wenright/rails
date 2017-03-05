local Player = Class {}

function Player:init()
	self.w, self.h = 32, 48

	self.x = 0
	self.y = (love.graphics.getHeight() * 3) / 4

	self.lastPosX = self.x

	self.r = 0
end

function Player:update(dt)
	-- TODO only calculate if needing to take curve
	self.lastPosX = self.x
	self.x = self.rail:getX()

	self.r = math.atan2(5, self.lastPosX - self.x) - math.pi / 2
end

function Player:draw()
	love.graphics.push()
	love.graphics.translate(self.x, self.y)
	love.graphics.rotate(self.r)

	love.graphics.setColor(Color[2])
	love.graphics.rectangle('line', -self.w / 2, -self.h / 2, self.w, self.h, 2)
	love.graphics.rectangle('fill', -self.w / 2, -self.h / 2, self.w, self.h, 2)

	love.graphics.pop()
end

function Player:setRail(rail)
	assert(rail, 'Tried to set nil rail')
	self.rail = rail

	if self.rail.type == 'deadend' then
		-- Game Over!
		error('Game over! You ran into a dead end')
	end
end

-- Recursively check if there is a route from the current rail to a head
function Player:pathCount()
	assert(self.rail, 'Player is not currently on a rail')

	local function checkPath(rail)
		if rail == nil then return 0 end

		if rail.head then
			if rail.type == 'deadend' then
				return 0
			else
				return 1
			end
		end

		if rail.type == 'branch' then
			return checkPath(rail.nextRailBranch) + checkPath(rail.nextRail)
		else
			return checkPath(rail.nextRail)
		end
	end

	return checkPath(self.rail)
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

return Player
