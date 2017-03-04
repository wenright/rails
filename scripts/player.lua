local Player = Class {}

function Player:init()
	self.w, self.h = 32, 48

	self.x = love.graphics.getWidth() / 2 - self.w / 2
	self.y = (love.graphics.getHeight() * 3) / 4
end

function Player:update(dt)

end

function Player:draw()
	love.graphics.setColor(Color[2])
	love.graphics.rectangle('line', self.x, self.y, self.w, self.h, 2)
	love.graphics.rectangle('fill', self.x, self.y, self.w, self.h, 2)
end

function love.mousepressed(x, y, button, isTouch)
	-- TODO switch rails
end

return Player