local Game = {}

function Game:init()
  self.player = Player()
  love.graphics.setBackgroundColor(Color[5])

  self.numBranches = 0
  
  self.rails = EntitySystem()

  self.rails:add(Rail())

  -- Let the game run for a bit, spawning enough rails to reach the end of the screen
  self.isWarmingUp = true

  local closestRail = nil
  while (self.isWarmingUp) do
    self.rails:forEach('update', 0.01)
    closestRail = Game:getClosestRail(Game.player.x, Game.player.y)
  end

  Game.player:setRail(closestRail)

  self.timer = Timer.new()

  self.camera = Camera(love.graphics.getWidth() - 32, love.graphics.getHeight() / 2)
  -- self.camera:zoom(0.5)
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

function Game:isRail(x, y)
  for k, rail in pairs(self.rails.pool) do
    if rail.x == x and rail.y <= y and rail.y + Rail.length >= y then
      return true
    end
  end

  return false
end

function Game:getClosestRail(x, y)
  for k, rail in pairs(self.rails.pool) do
    if rail.x == x and rail.y <= y and rail.y + Rail.length >= y then
      return rail
    end
  end

  return nil
end

return Game
