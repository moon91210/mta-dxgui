Window = Class('Window')


function Window.new(x, y, w, h, value)
	local self = inherit(Component.new("window", x, y, w, h), Window)

	self.value = value or ""
	self.titleh = 30
	self.offy = self.titleh
	self.styles = {
		closeButtonBackgroundColor = tocolor(55,55,165,255),
		closeButtonHoverBackgroundColor = tocolor(55,55,55,150),
		tabBackgroundColor = tocolor(0,0,0,245),
		backgroundColor = tocolor(20,20,20,235),
		borderColor = tocolor(55,55,255,155),
		fontFamily = "tahoma",
		strokeColor = tocolor(0,0,0,255),
		color = tocolor(255,255,255,255),
		borderSize = 1
	}

	local dragArea = DragArea(0, -self.offy, self.w, self.titleh):setParent(self)

	self.closeBtn = Button.new(self.w - self.titleh, 3, self.titleh-3, self.titleh-5, "×")
		:setParent(dragArea)
		:on('mouseup', function()
			self.visible = false
			self:emit('close')
			focus(2)
		end)

	self.closeBtn.styles.backgroundColor = self.styles.closeButtonBackgroundColor
	self.closeBtn.styles.hoverBackgroundColor = self.styles.closeButtonHoverBackgroundColor

	self:on('destroy', function()
		focus(1)
	end)

	self:focus()

	return self
end

function Window:draw()

	-- titlebar
	dxDrawRectangle(self.x, self.y, self.w, self.titleh, self.styles.tabBackgroundColor)
	dxDrawText(self.value, self.x+2, self.y+2, self.x + self.w+2, self.y + self.titleh+2, self.styles.strokeColor, 1.5, self.styles.fontFamily, "center", "center")
	dxDrawText(self.value, self.x, self.y, self.x + self.w, self.y + self.titleh, self.styles.color, 1.5, self.styles.fontFamily, "center", "center")
	-- main bg
	dxDrawRectangle(self.x, self.y + self.titleh, self.w, self.h - self.titleh, self.styles.backgroundColor)

	self:drawBorders()
end

setmetatable(Window, {__call = function(_, ...) return Window.new(...) end})