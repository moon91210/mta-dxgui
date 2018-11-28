Pane = Class('Pane')


function Pane.new(x, y, w, h)
	return inherit(Component.new('pane', x, y, w, h), Pane)
end

setmetatable(Pane, {__call = function(_, ...) return Pane.new(...) end})