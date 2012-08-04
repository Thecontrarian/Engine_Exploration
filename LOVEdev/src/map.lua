function loadMap(mapData)
		map = {}
		for i=0,mapData:getWidth()-1 do
			map[i] = {}
			for j=0,mapData:getHeight()-1 do
				if mapData:getPixel(j,i) == 0
					then map[i][j] = 0 --math.random(10000,1000000)%3
					--print(map[i][j])
				end
				if mapData:getPixel(j,i) == 255
					then map[i][j] = 1 --(math.random(10000,1000000)%2)+3
					--print(map[i][j])
				end
			end
		end
end

function generateMap(width, height)
	map = {}
	mapWidth = width
  mapHeight = height
	for i=0, height-1 do
		map[i] = {}
		for j=0, width-1 do
			-- make map border walls
--			if i == 0 or j == 0 or j == (width-1) or i == (height-1) then map[i][j] = 1
--			elseif i % 10 == 0 and j % 10 == 0 then map[i][j] = 1
--			else map[i][j] = 0
--			end 
		map[i][j] = 1
		end
	end
	
end