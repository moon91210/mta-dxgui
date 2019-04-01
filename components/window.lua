Window = Class('Window')


function Window.new(x, y, w, h, value)
	local self = inherit(Component.new("window", x, y, w, h), Window)

	self.value = value or ""
	self.titleh = 30
	self.offy = self.titleh
	
	local dragArea = DragArea(0, -self.offy, self.w, self.titleh):setParent(self)

	self.closeBtn = Button.new(self.w - self.titleh, 3, self.titleh-3, self.titleh-5, "×")
		:setParent(dragArea)
		:on('mouseup', function()
			self.visible = false
			self:emit('close')
			focus(2)
		end)
	
	self:on('destroy', function()
		focus(1)
	end)

	self:focus()

	return self
end

function Window:draw()
	local color = self.focused and tocolor(20,20,20,235) or tocolor(8,8,8,235)

	-- titlebar
	dxDrawRectangle(self.x, self.y, self.w, self.titleh, tocolor(0,0,0,245))
	dxDrawText(self.value, self.x+2, self.y+2, self.x + self.w+2, self.y + self.titleh+2, tocolor(0,0,0,255), 1.5, "tahoma", "center", "center")
	dxDrawText(self.value, self.x, self.y, self.x + self.w, self.y + self.titleh, tocolor(225,225,225,255), 1.5, "tahoma", "center", "center")
	-- main bg
	dxDrawRectangle(self.x, self.y + self.titleh, self.w, self.h - self.titleh, color)

	self:drawBorders(2, tocolor(55,55,255,155))
end

setmetatable(Window, {__call = function(_, ...) return Window.new(...) end})