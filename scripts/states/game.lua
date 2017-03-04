local Game = {}

function Game:init()
  self.player = Player()
  love.graphics.setBackgroundColor(Color[5])

  self.rails = EntitySystem()
  self.rails:add(Rail())

  self.timer = Timer.new()
end

function Game:update(dt)
  self.timer.update(dt)

  self.rails:forEach('update', dt)
  self.player:update(dt)
end

function Game:draw()
  self.rails:forEach('draw')
  self.player:draw()
end

return Game
