Checkbox = Class('Checkbox')


function Checkbox.new(x, y, w, h, value)
	local self = inherit(Component.new("checkbox", x, y, w, h), Checkbox)
	self.value = value
	self.selected = false

	self:on('mouseup', function(btn)
		self:toggle()
	end)

	return self
end

function Checkbox:draw()
	local co = self.h * 0.85

	dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(0,0,0,100))
	dxDrawRectangle(self.x, self.y, self.h, self.h, tocolor(0,0,0))
	if self.selected then
		dxDrawRectangle(self.x + co, self.y + co, self.h - co*2, self.h - co*2)
	end

	dxDrawText(self.value, self.x + self.h + 5, self.y, self.x + self.w - 5, self.y + self.h, tocolor(255,255,255), self.h * 0.05, "default", "left", "center", true)
end

function Checkbox:toggle()
	self.selected = not self.selected
	self:emit('toggle', self.selected)
end

setmetatable(Checkbox, {__call = function(_, ...) return Checkbox.new(...) end})