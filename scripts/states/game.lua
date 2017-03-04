local Game = {}

function Game:init()
  self.player = Player()
  love.graphics.setBackgroundColor(Color[5])

  self.numBranches = 0
  
  self.rails = EntitySystem()
  self.player.rail = self.rails:add(Rail())

  self.timer = Timer.new()

  self.camera = Camera(love.graphics.getWidth() - 32, love.graphics.getHeight() / 2)
end

function Game:update(dt)
  self.timer.update(dt)

  self.rails:forEach('update', dt)
  self.player:update(dt)
end

function Game:draw()
  self.camera:attach()

  self.rails:forEach('draw')
  self.player:draw()

  self.camera:detach()
end

return Game
