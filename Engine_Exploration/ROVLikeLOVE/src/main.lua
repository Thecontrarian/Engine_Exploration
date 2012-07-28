--[=[
TODO:
make map translation smooth
make areas outside of map either render as wall or not try to render and fuck up
create map_buffer_size exception

--]=]




function love.load()
	--	require "middleclass"
	--	require "boundingBoxes"
	require "map"
	width, height, fullscreen, vsync, fsaa = love.graphics.getMode()

--	mapPath = "gfx/testMap.png"
--	mapData = love.image.newImageData(mapPath)
--	loadMap(mapData)

	generateMap(5000,5000)

	map_w = (#map)+1 -- Obtains the width of the first row of the map, adds 1 because index starts at zero
	map_h = (#map[0])+1 -- Obtains the height of the map, adds 1 because index starts at zero
	--    map_x = 0
	--    map_y = 0
	tile_w = 32
	tile_h = 32
	offset_x = 0
	offset_y = 0
	inc_offset_x = 0
	inc_offset_y = 0
	map_display_buffer = 2 -- We have to buffer one tile before and behind our viewpoint.
	-- Otherwise, the tiles will just pop into view, and we don't want that.
	map_display_w = math.ceil(width/tile_w)
	map_display_h = math.ceil(height/tile_h)
	print("map is " .. map_display_w .. " wide and " .. map_display_h .. " tall")
	

	player = {
		grid_x = 256, -- increments of 32
		grid_y = 256,
		act_x = 200,
		act_y = 200,
		speed = 10 --
	}
	love.keyboard.setKeyRepeat(1,.5)
	love.mouse.setVisible(false)
	min_dt = 1/60  --	FPS to cap at
	next_time = love.timer.getMicroTime()	--	works to cap FPS
end

function testMap(x, y) -- enables collision
	if map[(player.grid_y / 32) + y][(player.grid_x / 32) + x] == 1 then
		return false
	end
	return true
end

function love.keypressed(key,unicode)
	if key == "escape" or key == "q" then
		love.event.push("quit")
	end
	if key == "d" then
		debug.debug()
	end
end

function love.update(dt)
	next_time = next_time + min_dt --	Caps FPS

	if love.keyboard.isDown("r") then -- resets
		player.grid_y = 256
		player.grid_x = 256
		offset_y = 0
		offset_x = 0
	end
	if love.keyboard.isDown("up") then -- moves player up 1
		if testMap(0, -1) then
			if offset_y ~= 0 and ((player.grid_y / 32) - offset_y - 1) <= 2 then-- this ensures offset panning doesnt exceed bounds of map
				offset_y = offset_y - 1
			end
			player.grid_y = player.grid_y - 32
		end
	elseif love.keyboard.isDown("down") then -- moves player down 1
		if testMap(0, 1) then
			if (offset_y + map_display_h + 1) < map_h -- this ensures offset panning doesnt exceed bounds of map
			and ((player.grid_y / 32) - offset_y + 1) >= map_display_h - 2 then
				offset_y = offset_y + 1
			end
			player.grid_y = player.grid_y + 32
		end
	end
	if love.keyboard.isDown("left") then -- moves player left 1
		if testMap(-1, 0) then
			if offset_x ~= 0 and ((player.grid_x / 32) - offset_x - 1) <= 2 then -- this ensures offset panning doesnt exceed bounds of map
				offset_x = offset_x - 1
			end
			player.grid_x = player.grid_x - 32
		end
	elseif love.keyboard.isDown("right") then -- moves player right 1
		if testMap(1, 0) then
			if (offset_x + map_display_w + 1) < map_w -- this ensures offset panning doesnt exceed bounds of map
			and ((player.grid_x / 32) - offset_x + 1) >= map_display_w - 2 then

				offset_x = offset_x + 1 --
			end
			player.grid_x = player.grid_x + 32
		end
	end
	if player.act_y ~= player.grid_y then
		if math.abs((player.act_y - player.grid_y) * dt * player.speed) <= 0.1 then -- so that it doesnt keep processing after the player has stopped moving
			player.act_y = player.grid_y
		else
			player.act_y = player.act_y - ((player.act_y - player.grid_y) * dt * player.speed) --  these smooth player movement
		end
	end
	if player.act_x ~= player.grid_x then
		if math.abs((player.act_x - player.grid_x) * dt * player.speed) <= 0.1 then -- so that it doesnt keep processing after the player has stopped moving
			player.act_x = player.grid_x
		else
			player.act_x = player.act_x - ((player.act_x - player.grid_x) * dt * player.speed) --  these smooth player movement
		end
	end
--	 	the inc_offsets jitters for some reason
--	if inc_offset_x ~= (offset_x * tile_w) then
--		if 
		inc_offset_x = inc_offset_x - ((inc_offset_x - (offset_x * tile_w)) * dt * player.speed)
		inc_offset_y = inc_offset_y - ((inc_offset_y - (offset_y * tile_h)) * dt * player.speed)

	--	print(inc_offset_y)
end

function draw_map()
--    offset_x = map_x % tile_w
--    offset_y = map_y % tile_h
--    firstTile_x = math.floor(map_x / tile_w)
--    firstTile_y = math.floor(map_y / tile_h)
--	
--
	if inc_offset_x ~= 0 then
		map_x = (inc_offset_x - (offset_x * tile_w)) % tile_w
	else
		map_x = 0
	end
	if inc_offset_y ~= 0 then
		map_y = (inc_offset_y - (offset_y * tile_h)) % tile_h
	else
		map_y = 0
	end
	for y=offset_y, (map_display_h + offset_y) do
		for x=offset_x, (map_display_w + offset_x) do
			if map[y][x] == 1 then
				love.graphics.rectangle("line",((x - offset_x) * 32) - map_x,((y - offset_y) * 32) - map_y,32,32)
			end
		end
	end

	
    
--    for y=1, (map_display_h + map_display_buffer) do
--        for x=1, (map_display_w + map_display_buffer) do
--            -- Note that this condition block allows us to go beyond the edge of the map.
--            if y+offset_y >= 1 and y+offset_y <= map_h
--                and x+offset_x >= 1 and x+firstTile_x <= map_w
--            then
--                love.graphics.draw(
--                    tile[map[y+firstTile_y][x+firstTile_x]], 
--                    ((x-1)*tile_w) - offset_x - tile_w/2, 
--                    ((y-1)*tile_h) - offset_y - tile_h/2)
--            end
--        end
--    end
	
end

function love.draw()
	mouse_x, mouse_y = love.mouse.getPosition( )
	--	love.graphics.line(0,0,x,y,width,height)
	--	love.graphics.line(width,0,x,y,0,height)
	love.graphics.setCaption("Zippy")
	draw_map()
	if 168 - (offset_x * 32) > -40 and 70 - (offset_y * 32) > -10 then
		love.graphics.print("Move with the arrow keys.\n\"r\" resets, esc to quit.",168 - (offset_x * 32),70 - (offset_y * 32),r,sx,sy,kx,ky)
	end
	love.graphics.rectangle("fill",player.act_x - (offset_x * tile_w),player.act_y - (offset_y * tile_h),32,32)
	love.graphics.print(player.act_x .. "\n" .. player.act_y .. "\n" .. player.grid_x .. "\n" .. player.grid_y .. "\n" .. inc_offset_y .. "\n" .. inc_offset_x .. "\n" .. offset_y .. "\n" .. offset_x .. "\n" .. map_x,mouse_x,mouse_y)
	--	the following caps FPS
	local cur_time = love.timer.getMicroTime()
	if next_time <= cur_time then
		next_time = cur_time
		return
	end
	love.timer.sleep((next_time - cur_time))

end

