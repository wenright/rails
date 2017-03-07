local Menu = {}

function Menu:resume()
	Gamestate.push(Game)
end

function Menu:enter()
  -- For now, just launch the game
  -- TODO start menu
  Gamestate.push(Game)
end

function Menu:update(dt)

end

function Menu:draw()

end

return Menu
