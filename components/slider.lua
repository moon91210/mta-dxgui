Slider = {}
local Seeker = {}


function Slider.new(x, y, w, h)
	local self = inherit(Component.new('Slider', x, y, w, h), Slider)
	self.seekerWidth = 8
	self.seeker = Seeker.new(0, 0, self.seekerWidth, h):setParent(self)
	self.trackHeight = 8
	return self
end

function Slider:draw()
	local seeker = self.seeker
	seeker.dragArea.dragging = mouseDown and (seeker.pos > 0 or mouseX > self.x) and (seeker.pos < 100 or mouseX < self.x + self.w)
	-- draw the slider track
	dxDrawRectangle(self.x, self.y + (self.h-self.trackHeight)/2, self.w, self.trackHeight, tocolor(0,0,0,225))
end

function Slider:setSeekerPosition(pos)
	check('n', {pos})
	assert(pos >= 0 and pos <= 100, 'position must be a value between 0-100')
	self.seeker:setPosition(map(pos, 0, 100, 0, self.w - self.seekerWidth))
	return self
end

function Slider:getSeekerPosition()
	return self.seeker.pos
end

function Slider:setSeekerWidth(width)
	check('n', {width})
	self.seekerWidth = width
	self.seeker.w = width
	return self
end

function Slider:setTrackHeight(height)
	check('n', {height})
	self.trackHeight = height
	return self
end

setmetatable(Slider, {__call = function(_, ...) return Slider.new(...) end})


function Seeker.new(x, y, w, h)
	local self = inherit(Component.new('Seeker', x, y, w, h), Seeker)
	self:setDraggable(true)
	self.pos = -1
	return self
end

function Seeker:draw()
	local parent = self.parent
	if parent then
		local x, y, w, h = self.x, self.y, self.w, self.h
		local pos = map(x, parent.x, parent.x + parent.w - w, 0, 100)
		if pos ~= self.pos then
			self.pos = pos
			self.parent:emit('change', pos)
		end

		dxDrawRectangle(x, y, w, h, tocolor(55,55,255,255), false, true)

		if self.dragArea.mouseDown or self.dragArea.mouseOver then
			dxDrawRectangle(x, y, w, h, tocolor(55,110,255,255), false, true)
		end
	end
end