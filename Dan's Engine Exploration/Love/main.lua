function love.load()
	image = love.graphics.newImage("gfx/tiles.bmp")
	image2 = image
	racesImage = love.graphics.newImage("gfx/races.png")
	blank = love.image.newImageData(800, 600)
	racesSpriteBatch = love.graphics.newSpriteBatch(image2, 260)
	races = {}
	tiles = {}
	sizeSq = 48          -- create the matrix
    for i=0,1 do
		races[i] = {}     -- create a new row
		for j=0,12 do
			races[i][j] = love.graphics.newQuad(i*sizeSq, j*sizeSq, sizeSq, sizeSq, racesImage:getWidth(), racesImage:getHeight())
		end
    end
    for i=0,0 do
		tiles[i] = {}     -- create a new row
		for j=0,4 do
			tiles[i][j] = love.graphics.newQuad(i*sizeSq, j*sizeSq, sizeSq, sizeSq, racesImage:getWidth(), racesImage:getHeight())
		end
    end
    for i=0,15 do
    	for j=0,15 do
    		racesSpriteBatch:addq(tiles[0][0], i*sizeSq, j*sizeSq)
    	end
    end
	x = 100
	y = 100
end

function love.draw()

    love.graphics.setBlendMode('alpha')
    love.graphics.setBackgroundColor(150,150,150)
    for i=0,1 do
		for j=0,12 do
			love.graphics.drawq(racesImage, races[i][j], i*90, j*90)
		end
	end
	love.graphics.draw(racesSpriteBatch, 0, 0)

		

    --love.graphics.draw(image2, 150, 150)
    -- love.graphics.print(races[5][5], 400, 300)
end