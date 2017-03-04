local Rail = Class {
	speed = 100,
	length = 128
}

function Rail:init(x, t)
	self.w, self.h = 32, Rail.length

	self.x = x or love.graphics.getWidth() / 2 - self.w / 2
	self.y = 0

	self.head = true

	-- TODO branch right type
	-- Either straight, branch, or deadend
	self.type = t or 'straight'

	if self.type == 'straight' then

	elseif self.type == 'branch' then
		local x, y = self.x, Rail.length

		self.curve1 = love.math.newBezierCurve({
			x + self.w, y,
			x + self.w + 8, y - 48,
			x + self.w + 32, y - 64,
			x + self.w + 56, y - 80,
			x + self.w + 64, y - 128
		})

		self.curve2 = love.math.newBezierCurve({
			x, y,
			x + 8, y - 48,
			x + 32, y - 64,
			x + 56, y - 80,
			x + 64, y - 128
		})

		self.points1 = self.curve1:render(5)
		self.points2 = self.curve2:render(5)

		self.bothCurves = self.points1
		for k, v in pairs(self.points2) do
			table.insert(self.bothCurves, v)
		end
		-- table.insert(self.bothCurves, self.points1[1])
		-- table.insert(self.bothCurves, self.points1[2])

		self.willTakeCurve = false
	elseif self.type == 'deadend' then

	end
end

function Rail:update(dt)
	self.y = self.y + dt * Rail.speed

	if self.head and self.y > self.length then
		-- TODO rail choice shouldn't be totally random, and make sure that there is always a path (not all deadends)
		if self.type == 'straight' then
			self.nextRail = self:addNewRail(self.x)
		elseif self.type == 'branch' then
			self.nextRail = self:addNewRail(self.x)
			self.nextRailBranch = self:addNewRail(self.x + self.w * 2)
		elseif self.type == 'deadend' then
			-- Do nothing
		end

		-- TODO decide which rail to put player on for branches
		Game.player.rail = self.nextRail

		self.head = false
	end 

	if self.y > love.graphics.getHeight() + Rail.length then
		Game.rails:remove(self)
	end
end

function Rail:draw()
	love.graphics.setColor(Color[3])

	-- TODO line thickness
	love.graphics.push()
	love.graphics.translate(0, self.y - Rail.length)
	love.graphics.setColor(Color[3])

	if self.type == 'straight' then
		love.graphics.rectangle('line', self.x, 0, self.w, self.h, 2)
	elseif self.type == 'branch' then
		love.graphics.rectangle('line', self.x, 0, self.w, self.h, 2)

		love.graphics.line(self.points1)
		love.graphics.line(self.points2)
	elseif self.type == 'deadend' then
		love.graphics.rectangle('line', self.x, self.h / 2, self.w, self.h / 2, 2)
		love.graphics.rectangle('fill', self.x, self.h / 2, self.w, self.h / 2, 2)
	end

	love.graphics.pop()
end

function Rail:getX()
	return self.x
end

function Rail:addNewRail(x)
	local newRail = nil

	if love.math.random() > 0.925 then
		-- TODO left and right branches. Make sure branch doesn't go off screen or overlap another track
		Game.numBranches = Game.numBranches + 1
		newRail = Game.rails:add(Rail(x or self.x, 'branch'))
		-- TODO and canHaveDeadend
		-- TODO this needs to be 'has2Paths'
	elseif love.math.random() > 0.8 and Game.numBranches > 1 then
		Game.numBranches = Game.numBranches - 1
		newRail = Game.rails:add(Rail(x or self.x, 'deadend'))
	else
		newRail = Game.rails:add(Rail(x or self.x, 'straight'))
	end

	return newRail
end

return Rail