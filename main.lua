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

DEBUG = false

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
  love.graphics.setColor(0, 255, 0)
  love.graphics.print(love.timer.getFPS(), 250, 450)
end

function love.keypressed(key)
  if key == 'escape' then love.event.quit() end
end
