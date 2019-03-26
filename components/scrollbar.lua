Scrollbar = Class('Scrollbar')
local Thumb = {}


function Scrollbar.new(x, y, w, h)
	local self = inherit(Component.new('Scrollbar', x, y, w, h), Scrollbar)
	self.min = 0
	self.max = 100
	self.thumb = Thumb.new(0, 0, w, w):setParent(self)
	return self
end

function Scrollbar:draw()
	local x, y, w, h = self.x, self.y, self.w, self.h
	local thumb = self.thumb
	thumb.dragArea.dragging = (mouseDown and mouseY < y+h and thumb.pos > self.min) or (mouseDown and mouseY > y and thumb.pos < self.max-1)
	dxDrawRectangle(x, y, w, h, tocolor(11,11,11,255))
end

function Scrollbar:setScrollPosition(pos)
	check('n', {pos})
	local min, max = self.min, self.max
	self.thumb:setPosition(0, math.max(0,map(constrain(pos, min, max), min, max, 0, self.h - self.thumb.h)))
	return self
end

function Scrollbar:getScrollPosition()
	return self.thumb.pos
end

function Scrollbar:setThumbHeight(h)
	check('n', {h})
	self.thumb:setHeight(math.max(15, h))
	return self
end

function Scrollbar:scrollOneUp()
	local min, max = self.min, self.max
	self.thumb:setPosition(0,  math.max(0,map(constrain(self.thumb.pos-1, min, max), min, max, 0, self.h - self.thumb.h)))
	return self
end

function Scrollbar:scrollOneDown()
	local min, max = self.min, self.max
	self.thumb:setPosition(0,  math.max(0,map(constrain(self.thumb.pos+1, min, max), min, max, 0, self.h - self.thumb.h)))
	return self
end

function Scrollbar:setMinMax(min, max)
	check('nn', {min, max})
	self.min = min
	self.max = max
	return self
end

setmetatable(Scrollbar, {__call = function(_, ...) return Scrollbar.new(...) end})


function Thumb.new(x, y, w, h)
	local self = inherit(Component.new('Thumb', x, y, w, h), Thumb)
	self.pos = -1
	self:setDraggable(true)
	return self
end

function Thumb:setHeight(h)
	self.dragArea.h = h
	self.h = h
end

function Thumb:draw()
	local parent = self.parent
	if parent then
		local x, y, w, h = self.x, self.y, self.w, self.h
		local pos = map(y, parent.y, parent.y + parent.h - h, parent.min, parent.max)

		if pos ~= self.pos then
			self.pos = pos
			self.parent:emit('change', pos)
		end

		local color = (self.dragArea.mouseDown or self.dragArea.mouseOver) and tocolor(55,110,255,255) or tocolor(55,55,255,255)
		dxDrawRectangle(x, y, w, h, color)
	end
end