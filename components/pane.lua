Pane = {}
Pane.__index = Pane


function Pane.new(x, y, w, h)
	local self = setmetatable(Component.new('pane', x, y, w, h), Pane)
	self.dragArea = DragArea(0, 0, self.w, self.h).setParent(self)
	self.debug = false
	return self
end

function Pane:draw()
	dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(55,55,55,220))
	if (self.debug) then
		dxDrawText(math.ceil(self.x)..", "..math.ceil(self.y), self.x, self.y, self.w, self.h)
	end
end

setmetatable(Pane, {__call = function(_, ...) return Pane.new(...) end})