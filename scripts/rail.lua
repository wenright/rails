local Rail = Class {
	length = 128
}

function Rail:init(x, t)
	self.w, self.h = 32, Rail.length

	self.x = x or 0
	self.y = 0

	self.head = true

	self.color = Color[1]
	self.disabledColor = Color[4]

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
		
		self.willTakeCurve = false
	elseif self.type == 'deadend' then

	end
end

function Rail:update(dt)
	self.y = self.y + dt * Game.speed

	if self.head and self.y > self.length then
		-- TODO rail choice shouldn't be totally random, and make sure that there is always a path (not all deadends)
		if self.type == 'straight' then
			self.nextRail = self:addNewRail(self.x)
		elseif self.type == 'branch' then
			-- TODO when adding rails that branch left, the ordering is going to change. Add the branch first so that the check later will catch branches on the side.
			self.nextRailBranch = self:addNewRail(self.x + self.w * 2)
			self.nextRail = self:addNewRail(self.x)
		elseif self.type == 'deadend' then
			-- Do nothing
		end

		self.head = false
	end

	if Game.player.rail == self and self.y >= Game.player.y + Rail.length then
		if self.type == 'deadend' then
			-- Game over. But this is handled in the player class
		else
			-- TODO decide which rail to put player on for branches
			if self.type == 'branch' and self.willTakeCurve then
				print('Taking curve')
				Game.player:setRail(self.nextRailBranch)
			else
				Game.player:setRail(self.nextRail)
			end
		end
	end

	if self.y > love.graphics.getHeight() + Rail.length then
		Game.isWarmingUp = false
		Game.rails:remove(self)
	end
end

function Rail:draw()
	love.graphics.setColor(self.color)

	-- TODO line thickness
	love.graphics.push()
	love.graphics.translate(-Game.player.w / 2, self.y - Rail.length)
	love.graphics.setColor(self.color)

	if self.type == 'straight' then
		love.graphics.rectangle('line', self.x, 0, self.w, self.h, 2)
	elseif self.type == 'branch' then
		if self.willTakeCurve then
			love.graphics.setColor(self.disabledColor)
		else
			love.graphics.setColor(self.color)
		end

		love.graphics.rectangle('line', self.x, 0, self.w, self.h, 2)

		if self.willTakeCurve then
			love.graphics.setColor(self.color)
		else
			love.graphics.setColor(self.disabledColor)
		end

		love.graphics.line(self.points1)
		love.graphics.line(self.points2)
	elseif self.type == 'deadend' then
		love.graphics.rectangle('line', self.x, self.h / 2, self.w, self.h / 2, 2)
		love.graphics.rectangle('fill', self.x, self.h / 2, self.w, self.h / 2, 2)
	end

	love.graphics.pop()
end

function Rail:getX()
	if self.willTakeCurve then
		local t = math.min(math.abs((self.y - Game.player.y) / Rail.length), 1)
		local x, y = self.curve2:evaluate(t)
		return x
	else
		return self.x
	end
end

function Rail:switch()
	self.willTakeCurve = not self.willTakeCurve
end

function Rail:addNewRail(x)
	if Game.isWarmingUp then
		return Game.rails:add(Rail(x or self.x, 'straight'))
	end

	local newRail = nil

	local branchProbability = 0.2
	local deadendProbability = 0.7

	if love.math.random() < branchProbability
			and not Game:isRail(self.x + self.w * 2, self.y)   -- Prevent branches from being built onto other rails
			and self.type ~= 'branch' then                     -- Don't allow 2 branches in a row (Maybe add this in later after sorting out the bugs)
		-- TODO left and right branches. Make sure branch doesn't go off screen or overlap another track
		Game.numBranches = Game.numBranches + 1
		newRail = Game.rails:add(Rail(x or self.x, 'branch'))
		-- TODO and canHaveDeadend
		-- TODO this needs to be 'has2Paths'
	elseif love.math.random() < deadendProbability then
		local hasPath, pathHead = Game.player:hasPath()

		if hasPath and pathHead ~= self then
			Game.numBranches = Game.numBranches - 1
			newRail = Game.rails:add(Rail(x or self.x, 'deadend'))
		else
			newRail = Game.rails:add(Rail(x or self.x, 'straight'))
		end
	else
		newRail = Game.rails:add(Rail(x or self.x, 'straight'))
	end

	return newRail
end

return Rail