Input = {}
Input.__index = Input


function Input.new(x, y, w, h, value)
	local self = inherit(Component.new("input", x, y, w, h), Input)
	self.value = value or ''
	self.masked = false
	self.readonly = false
	self.maxLength = nil
	self.active = false
	self.font = "default-bold"
	self.fontSize = 1.35
	self.bsHeld = false
	self.bsTick = nil
	self.charEvent = function(char)
		self:onChar(char)
	end
	return self
end

function Input:draw()
	local value = self.masked and ("*"):rep(#self.value) or self.value
	local textWidth = dxGetTextWidth(value, self.fontSize, self.font, false)

	dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(255,255,255,255))
	dxDrawText(value, self.x, self.y, self.x + self.w, self.y + self.h, tocolor(28, 27, 28, 255), self.fontSize, self.font, "left", "center", true, false, false, false, false)

	if (self.active and getTickCount() % 1000 < 500) then
		local x = textWidth < self.w and self.x + textWidth or self.x + self.w - 3
		local y = self.y + 2

		dxDrawRectangle(x, y+6, 2, self.h - 15, tocolor(22, 22, 22, 255), true)
	end

	if (self.bsHeld and getTickCount() > self.bsTick + 25) then
		self.bsTick = getTickCount()
		self.value = self.value:sub(1,-2)
	end
end

function Input:onChar(char)
	if (self.visible and self.active) then
		self.value = self.value..char
	else
		self:setActive(false)
	end
end

function Input:setActive(state)
	if (state) then
		if (not self.active) then
			guiSetInputMode("no_binds")
			addEventHandler("onClientCharacter", root, self.charEvent)
			self.active = true
		end
	else
		guiSetInputMode("allow_binds")
		removeEventHandler("onClientCharacter", root, self.charEvent)
		self.active = false
	end
	return self
end

function Input:onKey(key, down)
	if (self.readonly) then	return end

	if (key == 'mouse1') then
		self:setActive(self.mouseOver)
	elseif (key == 'backspace') then
		if (self.active and down) then
			self.value = self.value:sub(1,-2)
			self.bsHeld = true
			self.bsTick = getTickCount()+500
		else
			self.bsHeld = false
		end
	elseif (self.active and key == 'c' and not down) then
		if (getKeyState("lctrl")) then
			clipboard = self.value
		end
	elseif (self.active and key == 'v' and not down) then
		if (getKeyState("lctrl")) then
			self.value = self.value..clipboard
		end
	end
end

setmetatable(Input, {__call = function(_, ...) return Input.new(...) end})