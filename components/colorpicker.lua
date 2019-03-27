-- @TODO color sliders acting weird when updated through self:on('change')

local Pointer = {}

function ColorPicker()
	local r, g, b, a = 255, 255, 255, 255

	local self = Window(0, 0, 550, 350, 'Color Picker')
		:align('center')

	Button(10, 268, 120, 40, 'OK')
		:setParent(self)
		:on('mouseup', function() self.visible = false end)

	self.lbl = Label(10, 10, 120, 30, 'RGBA:', 1.2, tocolor(255,255,255), false, 'sans', 'left', 'center')
		:setParent(self)

	self.input = Input(10, 50, 120, 30)
		:setParent(self)

	self.img = Image(140, 10, 400, 300, './img/colorpicker.png')
		:setParent(self)

	local function updatePointer()
		if r and g and b then
			self:emit('change', r, g, b, a)
		end
	end

	local slider1 = Slider(10, 95, 120, 30)
		:setParent(self)
		:setMinMax(0,255)
		:on('change', function(pos)
			r = math.floor(pos)
			updatePointer()
		end)
	
	local slider2 = Slider(10, 125, 120, 30)
		:setParent(self)
		:setMinMax(0,255)
		:on('change', function(pos)
			g = math.floor(pos)
			updatePointer()
		end)

	local slider3 = Slider(10, 155, 120, 30)
		:setParent(self)
		:setMinMax(0,255)
		:on('change', function(pos)
			b = math.floor(pos)
			updatePointer()
		end)

	self:on('change', function(r,g,b,a)
		self.lbl.color = tocolor(r, g, b, a)
		self.input:setValue(string.format('%s, %s, %s, %s', r, g, b, a))
		slider1:setSeekerPosition(math.floor(r))
		slider2:setSeekerPosition(math.floor(g))
		slider3:setSeekerPosition(math.floor(b))
	end)

	local pointer = Pointer.new():setParent(self.img)

	local f = fileOpen(self.img:getPath())
	local pixels = dxConvertPixels(f:read(f.size), 'plain')
	f:close()
	local size = self.img:getNativeSize()

	self:on('update', function()
		if not self.img.mouseDown then return end

		local x = map(mouseX + self.x, self.x + self.img.x, self.x + self.img.x + self.img.w, 0, self.img.w)
		local y = map(mouseY + self.y, self.y + self.img.y, self.y + self.img.y + self.img.h, 0, self.img.h)
		
		x = constrain(x, 0, self.img.w)
		y = constrain(y, 0, self.img.h)
		pointer:setPosition(x, y)

		x = map(x, 0, self.img.w, 0, size.w-1)
		y = map(y, 0, self.img.h, 0, size.h-1)

		r, g, b, a = dxGetPixelColor(pixels, x, y)
		updatePointer()
	end)

	return self
end

function Pointer.new()
	return inherit(Component.new('pointer', 0,0,0,0), Pointer)
end

function Pointer:draw()
	local x, y, w, h = self.x, self.y, self.w, self.h
	dxDrawLine(x-10, y, x+10, y, tocolor(55,55,55), 3)
	dxDrawLine(x, y-10, x, y+10, tocolor(55,55,55), 3)
	dxDrawRectangle(x-2, y-2, 4, 4, tocolor(200,200,200))
end

