Label = Class('Label')


function Label.new(x, y, w, h, value, scale, color, shadowed, font, alignleft, aligntop, clip, wordBreak)
	local self = inherit(Component.new('label', x, y, w, h), Label)
	self.value = value or ''
	self.styles = {
		shadowVisible = false, 
		shadowColor = tocolor(0,0,0,255),
		backgroundVisible = false,
		backgroundColor =  tocolor(0,0,0,200),
		hoverBackgroundColor = tocolor(55,55,55,150),
		alignVertical = "top",
		alignHorizontal = "left",
		fontFamily = "default", 
		fontSize = 1, 
		textClip = false,
		wordBreak = false, 
		color = tocolor(255,255,255,255),
	}
	return self
end

function Label:draw()
	if self.styles.backgroundVisible then
		dxDrawRectangle(self.x, self.y, self.w, self.h, self.styles.backgroundColor)
	end
	if self.styles.shadowVisible then
		dxDrawText(self.value, self.x + 1, self.y + 1, self.x + self.w + 1, self.y + self.h + 1, self.styles.shadowColor, self.styles.fontSize, self.styles.fontFamily, self.styles.alignHorizontal, self.styles.alignVertical, self.styles.textClip, self.styles.wordBreak)
	end
	dxDrawText(self.value, self.x, self.y, self.x + self.w, self.y + self.h, self.styles.color, self.styles.fontSize, self.styles.fontFamily, self.styles.alignHorizontal, self.styles.alignVertical, self.styles.textClip, self.styles.wordBreak)
end

setmetatable(Label, {__call = function(_, ...) return Label.new(...) end})

