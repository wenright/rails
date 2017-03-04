Timer = require 'lib.hump.timer'
Gamestate = require 'lib.hump.gamestate'
Class = require 'lib.hump.class'
Camera = require 'lib.hump.camera'

EntitySystem = require 'scripts.entitysystem'

Color = require 'scripts.color'

Player = require 'scripts.player'
Rail = require 'scripts.rail'

Game = require 'scripts.states.game'
Menu = require 'scripts.states.menu'

DEBUG = true

function love.load()
  io.stdout:setvbuf('no')

  if DEBUG then
    print("lovebird started on port 8000")
  end

  Gamestate.registerEvents()
  Gamestate.switch(Menu)
end

function love.update(dt)
  Timer.update(dt)

  if DEBUG then
    -- TODO remove lovebird for releases
    require 'lib.lovebird.lovebird':update(dt)
  end
end

function love.draw()
  love.graphics.setColor(255, 255, 255)
  love.graphics.print(love.timer.getFPS())
end

function love.keypressed(key)
  if key == 'escape' then love.event.quit() end
end
