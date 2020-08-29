Button = Class('Button')


function Button.new(x, y, w, h, value)
	local self = inherit(Component.new("button", x, y, w, h), Button)
	self.value = value or ""
	self.styles = table.copy(DefaultStyles.Button)
	return self
end

function Button:draw()
	dxDrawRectangle(self.x, self.y, self.w, self.h, self.styles.backgroundColor)

	if self.mouseOver then
		dxDrawRectangle(self.x, self.y, self.w, self.h, self.styles.hoverBackgroundColor)
	end

	dxDrawText(self.value, self.x, self.y, self.x+self.w, self.y+self.h, self.styles.color, self.styles.fontSize, self.styles.fontFamily, "center", "center", true)
end

setmetatable(Button, {__call = function(_, ...) return Button.new(...) end})