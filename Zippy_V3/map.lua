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
	local _mapData = love.image.newImageData(width, height)
	
end