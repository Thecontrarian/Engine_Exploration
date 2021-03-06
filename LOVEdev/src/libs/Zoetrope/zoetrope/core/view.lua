-- Class: View
-- A view is a group that packages several useful objects with it.
-- It's helpful to use, but not required. When a view is created, it
-- automatically sets the.view for itself. the.view should be considered
-- a read-only reference. If you want to switch views, you *must* set
-- the app's view property instead.
--
-- Extends:
--		<Group>

View = Group:extend{
	-- Property: timer
	-- A built-in <Timer> object for use as needed.

	-- Property: tween
	-- A built-in <Tween> object for use as needed.

	-- Property: factory
	-- A built-in <Factory> object for use as needed.

	-- Property: focus
	-- A <Sprite> to keep centered onscreen.

	-- Property: focusOffset
	-- This shifts the view of the focus, if one is set. If both
	-- x and y properties are set to 0, then the view keeps the focus
	-- centered onscreen.
	focusOffset = { x = 0, y = 0 },

	-- Property: minVisible
	-- The view clamps its scrolling so that nothing above or to the left
	-- of these x and y coordinates is visible.
	minVisible = { x = -math.huge, y = -math.huge },

	-- Property: maxVisible
	-- This view clamps its scrolling so that nothing below or to the right
	-- of these x and y coordinates is visible.
	maxVisible = { x = math.huge, y = math.huge },

	-- private property: _tint
	-- used to implement tints.

	-- private property: _fx
	-- used to perform fades and flashes.

	new = function (self, obj)
		obj = self:extend(obj)

		obj.timer = Timer:new()
		obj:add(obj.timer)
		obj.tween = Tween:new()
		obj:add(obj.tween)
		obj.factory = Factory:new()

		-- set the.view briefly, so that during the onNew() handler
		-- we appear to be the current view
	
		local oldView = the.view

		the.view = obj
		if obj.onNew then obj:onNew() end

		-- then reset it so that nothing breaks for the remainder
		-- of the frame for the old, outgoing view members.
		-- our parent app will restore us into the.view at the top of the next frame
		-- exception: there was no old view.

		if oldView then the.view = oldView end
		return obj
	end,

	-- Method: loadLayers
	-- Loads layers from a Lua source file (as generated by Tiled -- http://mapeditor.org).
	-- Each layer is created as a <Group> and added to preserve its ordering. Tile layers
	-- are created as <Map> instances; object layers will try to create instances of a class
	-- named by the object's name property. If no class exists by this name, or the object
	-- has no name property, a gray fill will be created instead, as a placeholder. If the
	-- object has a property named _the, then this will set the.[whatever] to it.
	--
	-- Arguments:
	--		file - filename to load
	--
	-- Returns:
	--		nothing

	loadLayers = function (self, file)
		local ok, data = pcall(loadstring(Cached:text(file)))
		local _, _, directory = string.find(file, '^(.*[/\\])')
		directory = directory or ''

		if ok then
			-- store tile properties by gid
			
			local tileProtos = {}

			for _, tileset in pairs(data.tilesets) do
				for _, tile in pairs(tileset.tiles) do
					local id = tileset.firstgid + tile.id
					
					for key, value in pairs(tile.properties) do
						tile.properties[key] = tovalue(value)
					end

					tileProtos[id] = tile
					tileProtos[id].width = tileset.tilewidth
					tileProtos[id].height = tileset.tileheight
				end
			end

			for _, layer in pairs(data.layers) do
				if View[layer.name] then
					error('the View class reserves the ' .. layer.name .. ' property for its own use; you cannot load a layer with that name')
				end

				if STRICT and self[layer.name] then
					print('Warning: a property named ' .. layer.name .. ' already exists in the current view\n')
				end

				if layer.type == 'tilelayer' then
					local map = Map:new{ spriteWidth = data.tilewidth, spriteHeight = data.tileheight }
					map:empty(layer.width, layer.height)

					-- load tiles

					for _, tiles in pairs(data.tilesets) do
						map:loadTiles(directory .. tiles.image, Tile, tiles.firstgid)

						-- and mix in properties where applicable

						for i, tile in ipairs(tileProtos) do
							if map.sprites[i] then
								map.sprites[i]:mixin(tile.properties)
							end
						end
					end

					-- load tile data

					local x = 1
					local y = 1

					for _, val in ipairs(layer.data) do
						map.map[x][y] = val
						x = x + 1

						if x > layer.width then
							x = 1
							y = y + 1
						end
					end

					self[layer.name] = map
					self:add(map)
				elseif layer.type == 'objectgroup' then
					local group = Group:new()

					for _, obj in pairs(layer.objects) do
						-- roll in tile properties if based on a tile

						if obj.gid and tileProtos[obj.gid] then
							local tile = tileProtos[obj.gid]

							obj.name = tile.properties.name
							obj.width = tile.width
							obj.height = tile.height

							for key, value in pairs(tile.properties) do
								obj.properties[key] = tovalue(value)
							end
						end

						-- create a new object if the class does exist

						local spr

						if _G[obj.name] then
							obj.properties.x = obj.x
							obj.properties.y = obj.y
							obj.properties.width = obj.width
							obj.properties.height = obj.height

							spr = _G[obj.name]:new(obj.properties)
						else
							spr = Fill:new{ x = obj.x, y = obj.y, width = obj.width, height = obj.height, fill = { 128, 128, 128 } }
						end

						if obj.properties._the then
							the[obj.properties._the] = spr
						end

						group:add(spr)
					end

					self[layer.name] = group
					self:add(group)
				else
					error("don't know how to create a " .. layer.type .. " layer from file data")
				end
			end
		else
			error('could not load view data from file: ' .. data)
		end
	end,

	-- Method: clampTo
	-- Clamps the view so that it never scrolls past a sprite's boundaries.
	-- This only looks at the sprite's position at this instant in time,
	-- not afterwards.
	--
	-- Arguments:
	--		sprite - sprite to clamp to
	--
	-- Returns:
	--		nothing

	clampTo = function (self, sprite)
		self.minVisible.x = sprite.x
		
		if sprite.x + sprite.width > the.app.width then
			self.maxVisible.x = sprite.x + sprite.width
		else
			self.maxVisible.x = the.app.width
		end
		
		self.minVisible.y = sprite.y
		
		if sprite.y + sprite.height > the.app.height then
			self.maxVisible.y = sprite.y + sprite.height
		else
			self.maxVisible.y = the.app.height
		end
	end,

	-- Method: fade
	-- Fades out to a specified color over a period of time.
	--
	-- Arguments:
	--		color - color table to fade to, e.g. { 0, 0, 0 }
	--		duration - how long to fade out in seconds, default 1
	--		onComplete - function to call when done, passed the tween related to this
	-- Returns:
	--		nothing

	fade = function (self, color, duration, onComplete)
		local alpha = color[4] or 255
		self._fx = color
		self._fx[4] = 0
		self.tween:start{ target = self._fx, prop = 4, to = alpha, duration = duration or 1,
						   ease = 'quadOut', force = true, onComplete = onComplete }
	end,

	-- Method: flash
	-- Immediately flashes the screen to a specific color, then fades out.
	--
	-- Arguments:
	--		color - color table to flash, e.g. { 0, 0, 0 }
	--		duration - how long to restore normal view in seconds, default 1
	--		onComplete - function to call when done, passed the tween related to this
	--
	-- Returns:
	--		nothing

	flash = function (self, color, duration, onComplete)
		local s = self
		local done = function (t)
			t.target = nil
			if onComplete then onComplete(t) end
		end

		assert(type(color) == 'table', 'color to flash is ' .. type(color) .. ', not a table')
		color[4] = color[4] or 255
		self._fx = color
		self.tween:start{ target = self._fx, prop = 4, to = 0, duration = duration or 1,
						   ease = 'quadOut', force = true, onComplete = done }
	end,

	-- Method: tint
	-- Immediately tints the screen a color. To restore normal viewing,
	-- call this method again with no arguments.
	--
	-- Arguments:
	--		red - red component, 0-255
	--		green - green component, 0-255
	--		blue - blue component, 0-255
	--		alpha - alpha, 0-255, default 255
	--
	-- Returns:
	--		nothing

	tint = function (self, red, green, blue, alpha)
		alpha = alpha or 255

		if red and green and blue and alpha > 0 then
			self._tint = { red, green, blue, alpha }
		else
			self._tint = nil
		end
	end,

	update = function (self, elapsed)
		local screenWidth = the.app.width
		local screenHeight = the.app.height

		-- follow the focused sprite
		
		if self.focus and self.focus.width < screenWidth
		   and self.focus.height < screenHeight then
			self.translate.x = math.floor(- (self.focus.x + self.focusOffset.x) +
							   (screenWidth - self.focus.width) / 2)
			self.translate.y = math.floor(- (self.focus.y + self.focusOffset.y) +
							   (screenHeight - self.focus.height) / 2)
		end
		
		-- clamp translation to min and max visible
		
		if self.translate.x > - self.minVisible.x then
			self.translate.x = - self.minVisible.x
		end

		if self.translate.y > - self.minVisible.y then
			self.translate.y = - self.minVisible.y
		end
		
		if self.translate.x < screenWidth - self.maxVisible.x then
			self.translate.x = screenWidth - self.maxVisible.x
		end
		
		if self.translate.y < screenHeight - self.maxVisible.y then
			self.translate.y = screenHeight - self.maxVisible.y
		end

		Group.update(self, elapsed)
	end,

	draw = function (self, x, y)
		Group.draw(self, x, y)

		-- draw our fx and tint on top of everything

		if self._tint then
			love.graphics.setColor(self._tint)
			love.graphics.rectangle('fill', 0, 0, the.app.width, the.app.height)
			love.graphics.setColor(255, 255, 255, 255)
		end

		if self._fx then
			love.graphics.setColor(self._fx)
			love.graphics.rectangle('fill', 0, 0, the.app.width, the.app.height)
			love.graphics.setColor(255, 255, 255, 255)
		end
	end
}
