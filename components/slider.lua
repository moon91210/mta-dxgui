Slider = Class('Slider')
local Seeker = {}


function Slider.new(x, y, w, h)
	local self = inherit(Component.new('Slider', x, y, w, h), Slider)
	self.trackHeight = 6
	self.min = 0
	self.max = 100
	self.seeker = Seeker.new(0, 0, 20, h):setParent(self)
	return self
end

function Slider:draw()
	local seeker = self.seeker
	seeker.dragArea.dragging = mouseDown and (seeker.pos > self.min or mouseX > self.x) and (seeker.pos < self.max or mouseX < self.x + self.w)
	dxDrawRectangle(self.x, self.y + (self.h-self.trackHeight)/2, self.w, self.trackHeight, tocolor(0,0,0,225))
end

function Slider:setSeekerPosition(pos)
	check('n', {pos})
	local min, max = self.min, self.max
	self.seeker:setPosition(map(constrain(pos, min, max), min, max, 0, self.w - self.seeker.w), 0)
	return self
end

function Slider:getSeekerPosition()
	return self.seeker.pos
end

function Slider:setSeekerRadius(width)
	check('n', {width})
	self.seeker.w = width
	return self
end

function Slider:setTrackHeight(height)
	check('n', {height})
	self.trackHeight = height
	return self
end

function Slider:setMinMax(min, max)
	check('nn', {min, max})
	self.min = min
	self.max = max
	return self
end

setmetatable(Slider, {__call = function(_, ...) return Slider.new(...) end})


function Seeker.new(x, y, w, h)
	local self = inherit(Component.new('Seeker', x, y, w, h), Seeker)
	self.pos = -1
	self:setDraggable(true)
	return self
end

function Seeker:draw()
	local parent = self.parent
	if parent then
		local x, y, w, h = self.x, self.y, self.w, self.h
		local pos = map(x, parent.x, parent.x + parent.w - w, parent.min, parent.max)

		if pos ~= self.pos then
			self.pos = pos
			self.parent:emit('change', pos)
		end

		local color = (self.dragArea.mouseDown or self.dragArea.mouseOver) and tocolor(55,110,255,255) or tocolor(55,55,255,255)
		dxDrawImage(x, y + h/2 - w/2, w, w, './img/seeker.png', 0, 0, 0, color)
	end
end