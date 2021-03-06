entity = class('entity')

function entity:getBounds(image)
	self.upBound = image:getHeight() / 2
	self.downBound = image:getHeight()/2
	self.leftBound = image:getWidth()/2
	self.rightBound = image:getWidth()/2

	for i=0,image:getWidth() do
		for j=0,image:getHeight() do
			a, b, c, d = image:getPixel()
			if d == 0 then
				if i < self.leftBound then self.leftBound = i end
				if i > self.rightBound then self.rightBound = i end
				if j < self.upBound then self.upBound = j end
				if j > self.downBound then self.downBound = j end
			end
		end
	end
end

function entity:initialize(image1)
	entity.getBounds(image1)
end