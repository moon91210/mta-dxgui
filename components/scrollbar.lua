ScrollBar = Class('ScrollBar')


function ScrollBar.new(x, y, w, h)
	local self = inherit(Component.new('scrollBar', x, y, w, h), ScrollBar)
	return self
end

function ScrollBar:draw()
	local x, y, w, h = self.x, self.y, self.w, self.h
end

setmetatable(ScrollBar, {__call = function(_, ...) return ScrollBar.new(...) end})