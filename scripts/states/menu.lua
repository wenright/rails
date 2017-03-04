local Menu = {}

function Menu:enter()
  -- For now, just launch the game
  -- TODO start menu
  Gamestate.switch(Game)
end

function Menu:update(dt)

end

function Menu:draw()

end

return Menu
