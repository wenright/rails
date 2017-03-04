--- A collection of entities
-- @classmod EntitySystem

local Entities = Class {
	type = 'EntitySystem'
}

--- Initialize a new Entities object
function Entities:init()
  self.pool = {}
end

--- Add a new entity to the system
-- @return The object that was created and added
function Entities:add(obj)
	table.insert(self.pool, obj)
  return obj
end

--- Remove an entity from the system
-- @param e The entity to remove
function Entities:remove(e)
	for key, entity in pairs(self.pool) do
		if entity == e then
			self.pool[key] = nil
		end
	end
end

-- Removes and returns item at top of table
function Entities:pop()
  local e = self.pool[#self.pool]
  self.pool[#self.pool] = nil
  return e
end

-- Changes the places of the entities at position i and j
function Entities:swap(i, j)
  self.pool[i], self.pool[j] = self.pool[j], self.pool[i]
end

function Entities:getAll()
  return self.pool
end

function Entities:size()
  return #self.pool
end

function Entities:removeAll()
	-- local clone = Class.clone(self.pool)

  local clone = {}

  for _, entity in pairs(self.pool) do
    table.insert(clone, entity)
  end

  self.pool = {}

	return clone
end

--- Find the entity at the given point
-- @tparam number x The x coordinate to check
-- @tparam number y The y coordinate to check
-- @treturn Class The object at the given location, if there is one
function Entities:getAtPoint(x, y)
	for _, entity in pairs(self.pool) do
		if entity:checkCollision(x, y) then
			return entity
		end
	end
end

--- Loop over each object, calling the given function on each entity
-- @tparam function func The function that will be called for each entity
function Entities:forEach(fn, ...)
	for _, entity in pairs(self.pool) do
		assert(entity[fn], 'Function "' .. fn .. '" not found for this entity')
		entity[fn](entity, ...)
	end
end

return Entities
