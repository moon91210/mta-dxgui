Label = Class('Label')


function Label.new(x, y, w, h, value, scale, color, shadowed, font, alignleft, aligntop, clip, wordBreak)
	local self = inherit(Component.new('label', x, y, w, h), Label)
	self.value = value or ''
	self.scale = scale or 1
	self.color = color or tocolor(255,255,255,255)
	self.bgVisible = false
	self.bgColor = tocolor(0,0,0,200)
	self.shadow = shadowed or false
	self.font = font or 'default'
	self.alignleft = alignleft or 'left'
	self.aligntop = aligntop or 'top'
	self.clip = clip or false
	self.wordBreak = wordBreak or true
	return self
end

function Label:draw()
	if self.bgVisible then
		dxDrawRectangle(self.x, self.y, self.w, self.h, self.bgColor)
	end
	if self.shadow then
		dxDrawText(self.value, self.x + 1, self.y + 1, self.x + self.w + 1, self.y + self.h + 1, tocolor(0,0,0,255), self.scale, self.font, self.alignleft, self.aligntop, self.clip, self.wordBreak)
	end
	dxDrawText(self.value, self.x, self.y, self.x + self.w, self.y + self.h, self.color, self.scale, self.font, self.alignleft, self.aligntop, self.clip, self.wordBreak)
end

setmetatable(Label, {__call = function(_, ...) return Label.new(...) end})
