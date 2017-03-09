local Rail = Class {
	length = 128,
	offset = 0
}

function Rail:init(x, y, t)
	self.w, self.h = 32, Rail.length

	self.x = x or 0
	-- self.y = y or 0
	self.y = 0

	self.head = true

	self.color = Color[1]
	self.disabledColor = Color[4]

	-- TODO branch right type
	-- Either straight, branch, or deadend
	self.type = t or 'straight'

	if self.type == 'straight' then

	elseif self.type == 'branchRight' then
		local x, y = self.x, Rail.length

		self.curve = love.math.newBezierCurve({
			x +  0, y - 0,
			x +  8, y - 48,
			x + 32, y - 64,
			x + 56, y - 80,
			x + 64, y - 128
		})

		self.points = self.curve:render(5)

		self.willBranchRight = false
	elseif self.type == 'branchLeft' then
		local x, y = self.x, Rail.length

		self.curve = love.math.newBezierCurve({
			x -  0, y - 0,
			x -  8, y - 48,
			x - 32, y - 64,
			x - 56, y - 80,
			x - 64, y - 128
		})

		self.points = self.curve:render(5)

		self.willBranchLeft = false
	elseif self.type == 'deadend' then

	end
end

function Rail:update(dt)
	self.y = self.y + dt * Game.speed

	if self.head and self.y > self.length then
		-- TODO rail choice shouldn't be totally random, and make sure that there is always a path (not all deadends)
		if self.type == 'straight' then
			self.nextRail = self:addNewRail(self.x)
		elseif self.type == 'branchRight' then
			-- TODO when adding rails that branch left, the ordering is going to change. Add the branch first so that the check later will catch branches on the side.
			self.nextRailBranch = self:addNewRail(self.x + self.w * 2)
			self.nextRail = self:addNewRail(self.x)
		elseif self.type == 'branchLeft' then
			self.nextRail = self:addNewRail(self.x)
			self.nextRailBranch = self:addNewRail(self.x - self.w * 2)
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
			if (self.type == 'branchRight' and self.willBranchRight) or (self.type == 'branchLeft' and self.willBranchLeft) then
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
	love.graphics.translate(self.x - Game.player.w / 2, self.y - Rail.length)
	love.graphics.setColor(self.color)

	if self.type == 'straight' then
		love.graphics.rectangle('line', 0, 0, self.w, self.h, 2)
	elseif self.type == 'branchRight' then
		if self.willBranchRight then
			love.graphics.setColor(self.disabledColor)
		else
			love.graphics.setColor(self.color)
		end

		love.graphics.rectangle('line', 0, 0, self.w, self.h, 2)

		if self.willBranchRight then
			love.graphics.setColor(self.color)
		else
			love.graphics.setColor(self.disabledColor)
		end

		love.graphics.translate(-self.x, 0)
		love.graphics.line(self.points)

		love.graphics.translate(self.w, 0)
		love.graphics.line(self.points)
	elseif self.type == 'branchLeft' then
		if self.willBranchLeft then
			love.graphics.setColor(self.disabledColor)
		else
			love.graphics.setColor(self.color)
		end

		love.graphics.rectangle('line', 0, 0, self.w, self.h, 2)

		if self.willBranchLeft then
			love.graphics.setColor(self.color)
		else
			love.graphics.setColor(self.disabledColor)
		end

		love.graphics.translate(-self.x, 0)
		love.graphics.line(self.points)

		love.graphics.translate(self.w, 0)
		love.graphics.line(self.points)
	elseif self.type == 'deadend' then
		love.graphics.rectangle('line', 0, self.h / 2, self.w, self.h / 2, 2)
		love.graphics.rectangle('fill', 0, self.h / 2, self.w, self.h / 2, 2)
	end

	love.graphics.pop()
end

function Rail:getX()
	if self.willBranchRight or self.willBranchLeft then
		local t = math.min(math.abs((self.y - Game.player.y) / Rail.length), 1)
		local x, y = self.curve:evaluate(t)
		return x
	else
		return self.x
	end
end

function Rail:branchRight()
	if self.type == 'branchRight' then
		self.willBranchRight = true
	elseif self.type == 'branchLeft' then
		self.willBranchLeft = false	
	end
end

-- TODO left branching
function Rail:branchLeft()	
	if self.type == 'branchRight' then
		self.willBranchRight = false
	elseif self.type == 'branchLeft' then
		self.willBranchLeft = true	
	end
end

function Rail:addNewRail(x)
	if Game.isWarmingUp then
		return Game.rails:add(Rail(x or self.x, self.y - Rail.length, 'straight'))
	end

	-- TODO rather than probabilities, do something like 'after random(1 -> 4) rails, spawn deadend'
	-- TODO there is a possibility where it keeps branching right and not spawning any dead ends, causing there to be no branches on the players rail
	local branchProbability = 0.4
	local deadendProbability = 0.6

	if love.math.random() < branchProbability and self.type ~= 'branchRight' and self.type ~= 'branchLeft' then
		if love.math.random() < 0.5 then
			local adjacentRail = Game:getRail(self.x - self.w * 2, self.y)
			if adjacentRail then
				-- TODO merging rails
				-- local newRail = Game.rails:add(Rail(x or self.x, 'branchRight'))

				-- newRail.head = false
				-- adjacentRail.child = newRail

				-- return newRail
			else
				return Game.rails:add(Rail(x or self.x, self.y - Rail.length, 'branchLeft'))
			end
		else
			local adjacentRail = Game:getRail(self.x + self.w * 2, self.y)
			if adjacentRail then
				-- TODO merging rails
				-- local newRail = Game.rails:add(Rail(x or self.x, 'branchRight'))

				-- newRail.head = false
				-- adjacentRail.child = newRail

				-- return newRail
			else
				return Game.rails:add(Rail(x or self.x, self.y - Rail.length, 'branchRight'))
			end
		end
	end

	if love.math.random() < deadendProbability and not Game.player.rail.nextRail:isBranch() then
		local pathCount = Game.player:pathCount()
		local isBranch = self.type == 'branchRight' or self.type == 'branchLeft'
		if (isBranch and pathCount > 2) or (not isBranch and pathCount > 1) then
			return Game.rails:add(Rail(x or self.x, self.y - Rail.length, 'deadend'))
		end
	end

	return Game.rails:add(Rail(x or self.x, self.y - Rail.length, 'straight'))
end

function Rail:isBranch()
	return self.type == 'branchRight' or self.type == 'branchLeft'
end

return Rail
