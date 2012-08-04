function load()
	alive = {}
	for i=1, 100 do
		alive[i] = {}
		alive[i].x = i
		alive[i].y = i*2
	end
	newAlive = checkDead(alive)
	vp = initViewPort(8)
	leftX = findHorizOffset(vp)
	topY = findVertOffset(vp)
	x = 0
	y = 0
	min_dt = 1/60  --	FPS to cap at
	next_time = love.timer.getMicroTime()	--	works to cap FPS
	checkClock = 0
	interval = 3
end

function update(dt)
--	next_time = next_time + min_dt --	Caps FPS
--	checkClock = checkClock + dt
--	if math.ceil(checkClock) % interval == 0 then
--		displayGrid = updateGrid(displayGrid)
--		checkClock = checkClock + 1
--	end
--
--	
--	if love.keyboard.isDown("up")  then
--    vp.top = vp.top - 1
--    vp.bot = vp.bot - 1
--    topY = findVertOffset(vp)
--  end
--  if love.keyboard.isDown("down")  then
--    vp.top = vp.top + 1
--    vp.bot = vp.bot + 1
--    topY = findVertOffset(vp)
--  end
--  if love.keyboard.isDown("left")  then
--    vp.left = vp.left - 1
--    vp.right = vp.right - 1
--    leftX = findHorizOffset(vp)
--  end
--  if love.keyboard.isDown("right")  then
--    vp.left = vp.left + 1
--    vp.right = vp.right + 1
--    leftX = findHorizOffset(vp)
--  end

end

function draw()

end

function iterateGeneration(alive, generation)
	--[=[
	this function iterates through the list of living cells,
	for each cell iterating through its 8 surrounding cells,
	each of which it refrences against the list of living cells,
	then iterating through the 8 surrounding cells of any of first 8
	surrounding cells it doesnt find a reference to in the list of living cells,
	referenceing each of those cells against the list of living cells,
	in order to determine the number of living cells each of the first list
	of surrounding cells has as a neighbor.
	then, for each of those cells, if the number of living neighbors is exactly
	3, it creates a new entry in a new list of living cells, called newAlive,
	listing that cell as living.
	once the function has iterated over all of the entries in the original
	list of living cells, it returns the new list, newAlive, the generation, and the new population.
	
	in its iteration, it also determines whether or not each of the initial
	living cells will survive or not.
	
	the key feature that keeps this function from taking exponetially more
	time to execute as the population increases is that for each cell that is
	checked to see if living or not, it creates an entry in a list called 
	checked, indexed with the coordinates of the cell, with the value 1
	for living and 0 for dead. the function then, before
	--]=]
	local _population = 0
	local _generation = generation + 1
	local _alive = alive
	local _key, _value, _key2, _value2, _x, _y, _x2, _y2
	local _neighbors, _neighbors2
	local _checked = {} -- index of coords of locations checked this update cycle. indexed as checked.x.y, evaluating as 0 for dead, 1 for alive
	local _newAlive = {} -- index of newborns
	for _key,_value in ipairs(_alive) do
		_neighbors = 0
		if _checked[_value.x] == nil then
			_checked[_value.x] = {}
		end
		if _checked[_value.x][_value.y] ~= 1 then
			_checked[_value.x][_value.y] = 1
		end
		for _x = (_value.x)-1, (_value.x)+1 do
			if _checked[_x] == nil then
				_checked[_x] = {}
			end
			for _y = (_value.y)-1, (_value.y)+1 do
				if _checked[_x][_y] == nil then
					_checked[_x][_y] = 0
				end
				for _key2,_value2 in ipairs(_alive) do
					if _x == _value2.x and _y == _value2.x then 
						_checked[_x][_y] = 1 
						_neighbors = _neighbors + 1
						break 
					end
				end
				if _checked[_x][_y] == 0 then
					if _x ~= _value.x or _y ~= _value.y then
						_neighbors2 = 0
						for _x2 = _x-1, _x+1 do
							if _checked[_x2] == nil then _checked[_x2] = {} end
							for _y2 = _y-1, _y+1 do
								if _x2 ~= _x or _y2 ~= _y then
									if _checked[_x2][_y2] == nil then
										for _key2,_value2 in ipairs(_alive) do
											if _x2 == _value2.x and _y2 == _value2.y then
												_neighbors2 = _neighbors2 + 1
												_checked[_x2][_y2] = 1
												break
											end
											_checked[_x2][_y2] = 0
										end
									elseif _checked[_x2][_y2] == 0 then
									elseif _checked[_x2][_y2] == 1 then
										_neighbors2 = _neighbors2 + 1
									end
								end
							end
						end
						if _neighbors2 == 3 then
							_newAlive[(#_newAlive)+1] = {}
							_newAlive[(#_newAlive)].x = _x
							_newAlive[(#_newAlive)].y = _y
							_population = _population + 1
						end
					end
				end
			end
		end
		if _neighbors == 3 or _neighbors == 2 then
			_newAlive[(#_newAlive)+1] = {}
			_newAlive[(#_newAlive)].x = _value.x
			_newAlive[(#_newAlive)].y = _value.y
			_population = _population + 1
		end
	end
	return _newAlive, _generation, _population
end