local Game = {}

function Game:init()
  self.timer = Timer.new()

  self.player = Player()
  love.graphics.setBackgroundColor(Color[5])

  -- self.grit = love.graphics.newImage('grit/grit.png')
  self.grit = love.graphics.newImage('grit/grit_sheet.png')

  self.speed = 300
  -- 1 minute of difficulty increase, whereafter difficulty remains the same. Could make it infinite, but it may get way too crazy fast
  -- self.timer.tween(120, self, {speed = 1250}, 'linear')

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

  self.gritY = 0

  self.camera = Camera(0, love.graphics.getHeight() / 2)

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

    self.gritY = self.gritY + Game.speed * dt
    if self.gritY >= self.grit:getHeight() / 2 then
      self.gritY = self.gritY - self.grit:getHeight() / 2
    end

    self.rails:forEach('update', dt)
    self.player:update(dt)

    self.camera:lockX(Game.player.x, Camera.smooth.damped(10))
  end
end

function Game:draw()
  love.graphics.setColor(Color[4])
  local w, h = love.graphics.getDimensions()
  local iw, ih = self.grit:getDimensions()
  local sx, sy = w / iw, h / ih
  love.graphics.draw(self.grit, 0, self.gritY, 0, sx, sy)
  love.graphics.draw(self.grit, 0, self.gritY - self.grit:getHeight() / 2, 0, sx, sy)  

  self.camera:attach()

  self.rails:forEach('draw')
  self.player:draw()

  self.camera:detach()

  -- love.graphics.setColor(Color[4])
  -- local w, h = love.graphics.getDimensions()
  -- local iw, ih = self.grit:getDimensions()
  -- local sx, sy = w / iw, h / ih
  -- love.graphics.draw(self.grit, 0, 0, 0, sx, sy)

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
  Game.player:switchRails()
end

function Game:keypressed(key)
  if key == 'p' then
    self.paused = not self.paused
  else
    Game.player:switchRails()
  end
end

return Game
