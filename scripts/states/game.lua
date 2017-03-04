local Game = {}

function Game:init()
  self.timer = Timer.new()

  self.player = Player()
  love.graphics.setBackgroundColor(Color[5])

  self.speed = 200
  -- 1 minute of difficulty increase, whereafter difficulty remains the same. Could make it infinite, but it may get way too crazy fast
  self.timer.tween(60, self, {speed = 1000}, 'linear')

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

  self.camera = Camera(0, love.graphics.getHeight() / 2)
end

function Game:update(dt)
  if not self.paused then
    self.timer.update(dt)

    self.rails:forEach('update', dt)
    self.player:update(dt)

    self.camera:lockX(Game.player.x, Camera.smooth.damped(10))
  end
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

function Game:mousepressed(x, y, button, isTouch)
  Game.player:switchRails()
end

function Game:keypressed(key)
  if key == 'p' then
    self.paused = not self.paused
  end
end

return Game
