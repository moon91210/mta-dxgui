RadioButton = Class('RadioButton')


function RadioButton.new(x, y, w, h, value)
	local self = inherit(Component.new("RadioButton", x, y, w, h), RadioButton)
	self.value = value
	self.selected = false

	self:on('mouseup', function(btn)
		if self.parent then
			local btns = self.parent:getChildren('RadioButton')
			for i=1, #btns do
				if btns[i] ~= self then
					btns[i]:select(false)
				end
			end
		end
		self:select(true)
	end)

	return self
end

function RadioButton:draw()
	local co = self.h * 0.85

	dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(0,0,0,100))
	dxDrawImage(self.x + co, self.y + co, self.h - co*2, self.h - co*2, 'img/seeker.png', 0, 0, 0, tocolor(13,13,13,255))
	if self.selected then
		dxDrawImage(self.x + co, self.y + co, self.h - co*2, self.h - co*2, 'img/seeker.png')
	end

	dxDrawText(self.value, self.x + self.h + 5, self.y, self.x + self.w - 5, self.y + self.h, tocolor(255,255,255), self.h * 0.05, "default", "left", "center", true)
end

function RadioButton:select(state)
	self.selected = state
end

setmetatable(RadioButton, {__call = function(_, ...) return RadioButton.new(...) end})