local Game = {}

function Game:init()
  self.timer = Timer.new()

  self.player = Player()
  love.graphics.setBackgroundColor(Color[5])

  self.speed = 300
  self.timer.tween(120, self, {speed = 1250}, 'linear')

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
  self.camera:zoom(1.5)

  -- TODO camera zooming based on screen size
  -- self.camera:zoom(love.graphics.getWidth() / 600)
  self.camera:zoom(1)

  -- TODO load highscore from a save file
  self.highscore = 0

  self.score = 0
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

  love.graphics.setColor(Color[1])
  love.graphics.print('HI ' .. self.highscore)
  love.graphics.print('   ' ..  self.score, 0, 40)
end

function Game:getRail(x, y)
  for k, rail in pairs(self.rails.pool) do
    if rail.x == x and rail.y <= y and rail.y + Rail.length >= y then
      return rail
    end
  end

  return nil
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
  -- Game.player:switchRails()
  self.mouseStart = {x = x, y = y}
end

function Game:mousemoved(x, y, dx, dy)
  if self.mouseStart then
    local dist = math.sqrt((x - self.mouseStart.x)^2 + (y - self.mouseStart.y)^2)
    local sign = x - self.mouseStart.x

    local gate = 20

    if dist >= gate then
      if sign > 0 then
        print('Swipe right')
        Game.player:swipeRight()
      else
        print('Swipe left')
        Game.player:swipeLeft()
      end

      self.mouseStart = nil
    end
  end
end

function Game:mousereleased(x, y)
  self.mouseStart = nil
end

function Game:keypressed(key)
  if key == 'p' then
    self.paused = not self.paused
  else
    -- Game.player:switchRails()
  end
end

return Game
