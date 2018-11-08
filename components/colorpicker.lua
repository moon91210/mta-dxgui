function ColorPicker()
	local self = Window(0, 0, 550, 350, 'Color Picker')
		:align('center')

	self.button = Button(10, 268, 120, 40, 'OK')
		:setParent(self)

	self.lbl = Label(10, 10, 120, 30, 'RGBA:', 1.2, tocolor(255,255,255), false, 'sans', 'left', 'center')
		:setParent(self)

	self.input = Input(10, 50, 120, 30)
		:setParent(self)

	self.img = Image(140, 10, 400, 300, './img/colorpicker.png')
		:setParent(self)

	local pixels = self.img:getTexture():getPixels()
	local size = self.img:getNativeSize()

	self.img:on('click', function()
		local sw, sh = guiGetScreenSize()

		local x = map(mouseX + self.x, self.x + self.img.x, self.x + self.img.x + self.img.w, 0, self.img.w)
		local y = map(mouseY + self.y, self.y + self.img.y, self.y + self.img.y + self.img.h, 0, self.img.h)

		x = map(x, 0, self.img.w, 0, size.w)
		y = map(y, 0, self.img.h, 0, size.h)

		local r, g, b, a = dxGetPixelColor(pixels, x, y)

		self.lbl.color = tocolor(r, g, b, a)
		self.input:setValue(string.format('%s, %s, %s, %s', r, g, b, a))
		self:emit('color', r, g, b, a)
	end)

	return self
end

