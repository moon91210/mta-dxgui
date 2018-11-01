ProgressBar = {}


function ProgressBar.new(x, y, w, h)
	local self = inherit(Component.new('progressbar', x, y, w, h), ProgressBar)
	self.progress = 0
	self.padding = 4
	return self
end

function ProgressBar:draw()
	local x, y, w, h = self.x, self.y, self.w, self.h
	local padding = self.padding
	local progress = self.progress

	dxDrawRectangle(x, y, w, h, tocolor(0,0,0,225))
	dxDrawRectangle(x + padding, y + padding, (w - padding*2) * progress, h - padding*2, tocolor(55,55,255,255), false, true)
	dxDrawText(progress*100 .. '%', x, y, x + w, y + h, tocolor(255,255,255), 1.5, 'arial', 'center', 'center')
end

function ProgressBar:setProgress(value)
	if tonumber(value) then
		self.progress = constrain(value, 0, 1)
	end
	return self
end

setmetatable(ProgressBar, {__call = function(_, ...) return ProgressBar.new(...) end})