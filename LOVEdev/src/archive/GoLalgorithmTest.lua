function load()
	alive = {}
	alive[1] = {}
	alive[1].x = 1
	alive[1].y = 3
	alive[2] = {}
	alive[2].x = 2
	alive[2].y = 3
	alive[3] = {}
	alive[3].x = 3
	alive[3].y = 3
	alive[4] = {}
	alive[4].x = 3
	alive[4].y = 2
	alive[5] = {}
	alive[5].x = 2
	alive[5].y = 1
--	live = {}
--	addToNewAliveList(live, 2, 1)
--	addToNewAliveList(live, 2, 2)
--	addToNewAliveList(live, 2, 3)
--	index = createAliveIndex(live)
	generation = 0
end

function iterateGeneration(aliveList, generation)
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
	if generation == nil then generation = 0 end
	local _generation = generation + 1
	local newAliveList = fillNewAliveList(aliveList)
	local population = #newAliveList
	return newAliveList, _generation, population
end

function checkIfAdded(list, x, y) 
	local _list = list
	if _list.added[x] == nil then
		return false
	elseif _list.added[x][y] == nil then
		return false
	else
		return true
	end
end

function addToAdded(list, x, y) 
	local _list = list
	if _list.added[x] == nil then
		_list.added[x] = {}
		_list.added[x][y] = 1
	elseif _list.added[x][y] == nil then
		_list.added[x][y] = 1
	end
	return _list
end

function addToTable(newAliveList, x, y, neighbors, level) 
	if level == 1 and (neighbors == 2 or neighbors == 3)then
		addToNewAliveList(newAliveList, x, y)
	elseif level == 2 and neighbors == 3 then
		addToNewAliveList(newAliveList, x, y)
	end
end

function addToNewAliveList(newAliveList, x, y)
	if (checkIfAdded(newAliveList, x, y) == false) then
		newAliveList[(#newAliveList)+1] = {}
		newAliveList[(#newAliveList)].x = x 
		newAliveList[(#newAliveList)].y = y
		newAliveList = addToAdded(newAliveList, x, y)
	end
end

function createAliveIndex(aliveList) -- tested, works
	local aliveIndex = {}
	for entry,pntr in ipairs(aliveList) do
		if aliveIndex[pntr.x] == nil then
			aliveIndex[pntr.x] = {}
			aliveIndex[pntr.x][pntr.y] = 1
		elseif aliveIndex[pntr.x][pntr.y] == nil then
			aliveIndex[pntr.x][pntr.y] = 1
		end
	end
	return aliveIndex
end

function checkAgainstIndex(aliveIndex, x, y, neighbors) -- tested, works
	local dead
	if aliveIndex[x] == nil then
		dead = true
		return neighbors, dead
	elseif aliveIndex[x][y] == 1 then
		neighbors = neighbors + 1
		dead = false
		return neighbors, dead
	end
	dead = true
	return neighbors, dead
end

function deadCellRules(index, newList, x, y) -- tested, works
	local neighbors = 0
	local _x, _y
	local _newList = newList
	for _x = x-1, x+1 do
		for _y = y-1, y+1 do
			if _x ~= x or _y ~= y then
				neighbors, dead = checkAgainstIndex(index, _x, _y, neighbors)
			end
		end
	end
	addToTable(_newList, x, y, neighbors, 2)
	return _newList
end

function fillNewAliveList(aliveList)
	local newAliveList = {}
	newAliveList.added = {}
	local aliveIndex = createAliveIndex(aliveList)
	local entry, pntr
	for entry, pntr in ipairs(aliveList) do
		local neighbors = 0
		local x, y, dead
		for x = (pntr.x)-1, (pntr.x)+1 do
			for y = (pntr.y)-1, (pntr.y)+1 do
				if x ~= pntr.x or y ~= pntr.y then
					neighbors, dead = checkAgainstIndex(aliveIndex, x, y, neighbors)
				end
				if dead == true then --enters inner
					newAliveList = deadCellRules(aliveIndex, newAliveList, x, y)
				end --exits inner
			end
		end
		addToTable(newAliveList, pntr.x, pntr.y, neighbors, 1)
	end
	newAliveList.added = nil
	return newAliveList
end


load()
alive, generation, population = iterateGeneration(alive, generation)
print()
