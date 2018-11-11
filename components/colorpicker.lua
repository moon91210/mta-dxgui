local Pointer = {}

function ColorPicker()
	local self = Window(0, 0, 550, 350, 'Color Picker')
		:align('center')

	self.button = Button(10, 268, 120, 40, 'OK')
		:setParent(self)

	self.lbl = Label(10, 10, 120, 30, 'RGBA:', 1.2, tocolor(255,255,255), false, 'sans', 'left', 'center')
		:setParent(self)

	self.input = Input(10, 50, 120, 30)
		:setParent(self)

	self.img = Image(140, 10, 400, 300, './img/colorpicker2.jpg')
		:setParent(self)

	local pointer = Pointer.new():setParent(self.img)

	local pixels = self.img:getTexture():getPixels()
	local size = self.img:getNativeSize()

	self:on('update', function()
		if not self.img.mouseDown then return end

		local x = map(mouseX + self.x, self.x + self.img.x, self.x + self.img.x + self.img.w, 0, self.img.w)
		local y = map(mouseY + self.y, self.y + self.img.y, self.y + self.img.y + self.img.h, 0, self.img.h)
		
		x = constrain(x, 0, self.img.w)
		y = constrain(y, 0, self.img.h)
		pointer:setPosition(x, y)

		x = map(x, 0, self.img.w, 0, size.w)
		y = map(y, 0, self.img.h, 0, size.h)

		local r, g, b, a = dxGetPixelColor(pixels, x, y)
		if r then
			self.lbl.color = tocolor(r, g, b, a)
			self.input:setValue(string.format('%s, %s, %s, %s', r, g, b, a))
			self:emit('change', r, g, b, a)
		end
	end)

	return self
end

function Pointer.new()
	return inherit(Component.new('pointer', 0,0,0,0), Pointer)
end

function Pointer:draw()
	local x, y, w, h = self.x, self.y, self.w, self.h
	dxDrawLine(x-10, y, x+10, y, tocolor(255,255,200), 2)
	dxDrawLine(x, y-10, x, y+10, tocolor(255,255,200), 2)
	self:drawBorders(2)
end

