local Game = {}

function Game:enter()
  -- TODO only set the random seed for debugging
  love.math.setRandomSeed(1489351354)
  print(love.math.getRandomSeed())

  self.timer = Timer.new()

  self.player = Player()

  self.highscore = self:readHighscore()
  self.hasBrokenHighscore = false
  
  -- Don't flash score if they are playing for the first time
  if self.highscore == 0 then
    self.hasBrokenHighscore = true
  end

  self.score = 0
  self.scoreColor = Color[1]

  love.graphics.setBackgroundColor(Color[5])

  self.speed = 300
  self.timer.tween(120, self, {speed = 1100}, 'linear')

  self.camera = Camera(0, love.graphics.getHeight() / 2)

  -- TODO we can't zoom since this messes with the levels ability to be beaten, but need a way to make the game always same size(ish) on all devices
  -- self.camera:zoom(1)

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

  self.over = false
end

function Game:update(dt)
  if not self.paused and not Game.over then
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

  love.graphics.setColor(self.scoreColor)
  love.graphics.print('HI\t' .. self.highscore)
  love.graphics.print('\t\t' ..  self.score, 0, 40)

  if Game.over then
    love.graphics.printf('Game Over!\nTap to retry', 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), 'center')
  end
end

function Game:getRail(x, y)
  for k, rail in pairs(self.rails.pool) do
    if rail.y <= y and rail.y + Rail.length >= y then
      if rail:isBranch() and (rail.x == x or rail.x + rail.w == x) then
        return rail
      elseif math.abs(rail.x - x) <= 10 then
        return rail
      end
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

  if Game.over then
    -- Restart game
    print('New game')
    Gamestate.pop()
  else
    self.mouseStart = {x = x, y = y}
  end
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
  if not Game.over then
    if key == 'p' then
      self.paused = not self.paused
    elseif key == 'right' or key == 'd' then
      Game.player:swipeRight()
    elseif key == 'left' or key == 'a' then
      Game.player:swipeLeft()  
    else
      -- Game.player:switchRails()
    end
  end
end

function Game:gameOver()
  Game:updateHighscore()
  Game:writeHighscore()

  Game.speed = 0
  Game.over = true
end

function Game:updateHighscore()
  if self.score > self.highscore then
    self.highscore = self.score

    if not self.hasBrokenHighscore then
      self.hasBrokenHighscore = true
      local blinkTime = 0.5

      self.timer.every(blinkTime, function()
        self.scoreColor = Color[5]

        self.timer.after(blinkTime / 2, function()
          self.scoreColor = Color[1]
        end)
      end, 3)
    end
  end
end

function Game:writeHighscore()
  local success = love.filesystem.write('highscore.txt', self.highscore)

  if success then
    print('Saved high score successfully')
  else
    error('Unable to save high score!')
  end
end

function Game:readHighscore()
  local str = love.filesystem.read('highscore.txt')
  return tonumber(str) or 0  
end

function Game:incrementScore()
  Game.score = Game.score + 1
  Game:updateHighscore()
end

function Game:quit()
  Game:updateHighscore()
  Game:writeHighscore()
end

return Game
