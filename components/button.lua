Button = Class('Button')


function Button.new(x, y, w, h, value)
	local self = inherit(Component.new("button", x, y, w, h), Button)
	self.value = value or ""
	self.color = tocolor(55,55,165,255)
	return self
end

function Button:draw()
	if self.mouseDown and self.mouseOver then
		dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(155,155,55,150))
	end

	dxDrawRectangle(self.x, self.y, self.w, self.h, self.color)
	-- dxDrawImage(self.x, self.y, self.w, self.h, "img/button.png", 0,0,0, tocolor(55,55,55,255))

	if self.mouseOver then
		dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(55,55,55,150))
	end

	dxDrawText(self.value, self.x, self.y, self.x+self.w, self.y+self.h, tocolor(255,255,255,255), 1.25, "default", "center", "center", true)
end

setmetatable(Button, {__call = function(_, ...) return Button.new(...) end})