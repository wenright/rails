local Player = Class {}

function Player:init()
	self.w, self.h = 32, 48

	self.x = love.graphics.getWidth() / 2 - self.w / 2
	self.y = (love.graphics.getHeight() * 3) / 4
end

function Player:update(dt)
	if self.rail.type == 'deadend' then
		print('Gameover')
	end

	self.x = self.rail:getX()
end

function Player:draw()
	love.graphics.setColor(Color[2])
	love.graphics.rectangle('line', self.x, self.y, self.w, self.h, 2)
	love.graphics.rectangle('fill', self.x, self.y, self.w, self.h, 2)
end

function Player:setRail(rail)
	self.rail = rail
end

-- Recursively check if there is a route from the current rail to a head
function Player:hasPath()
	assert(self.rail, 'Player is not currently on a rail')

	local function checkPath(rail)
		if rail.head then
			return rail.type ~= 'deadend'
		end

		if rail.type == 'branch' then
			return checkPath(rail.nextRail) or checkPath(rail.nextRailBranch)
		else
			return checkPath(rail.nextRail)
		end
	end

	-- return checkPath(self.rail)
	local yeah = checkPath(self.rail)
	print(yeah)
	return yeah
end

function love.mousepressed(x, y, button, isTouch)
	-- TODO switch rails
end

return Player