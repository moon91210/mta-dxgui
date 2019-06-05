Input = Class('Input')

local pasteEdit

function Input.new(x, y, w, h, value)
	local self = inherit(Component.new("input", x, y, w, h), Input)
	self.value = value or ''
	self.masked = false
	self.readOnly = false
	self.maxLength = nil
	self.active = false
	self.font = "tahoma"
	self.fontSize = 1.35
	self.backspaceHeld = false
	self.backspaceTick = nil
	self.charEvent = function(char) self:onChar(char) end
	return self
end

function Input:draw()
	local value = self.masked and ("*"):rep(#self.value) or self.value
	local textWidth = dxGetTextWidth(value, self.fontSize, self.font, false)

	dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(255,255,255,255))
	dxDrawText(value, self.x, self.y, self.x + self.w, self.y + self.h, tocolor(28, 27, 28, 255), self.fontSize, self.font, "left", "center", true, false, false, false, false)

	if self.active and getTickCount() % 1000 < 500 then
		local x = textWidth < self.w and self.x + textWidth or self.x + self.w - 3
		local y = self.y + 2

		dxDrawRectangle(x, y+6, 2, self.h - 15, tocolor(22, 22, 22, 255), true)
	end

	if self.backspaceHeld and getTickCount() > self.backspaceTick + 25 then
		self.backspaceTick = getTickCount()
		self.value = self.value:sub(1,-2)
	end
end

function Input:setMasked(state)
	check('b', {state})
	self.masked = state
end

function Input:setActive(state)
	check('b', {state})
	if state then
		if not self.active then
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

function Input:onChar(char)
	if self.visible and self.active then
		self.value = self.value..char
	else
		self:setActive(false)
	end
end

function Input:onKey(key, down)
	if self.readOnly then return end

	if key == 'mouse1' then
		self:setActive(self.mouseOver)
	elseif key == 'backspace' then
		if self.active and down then
			self.value = self.value:sub(1,-2)
			self.backspaceHeld = true
			self.backspaceTick = getTickCount()+500
		else
			self.backspaceHeld = false
		end
	elseif self.active and key == 'c' and not down then
		if getKeyState("lctrl") then
			setClipboard(self.value)
		end
	elseif self.active and key == 'v' and not down then
		if getKeyState("lctrl") then
			if isElement(pasteEdit) then
				self.value = self.value..pasteEdit.text
				pasteEdit:destroy()
			end
		end
	elseif self.active and key == 'enter' and down then
		self:emit('accepted')
		self:setActive(false)
	end

	if self.active then
		if not isElement(pasteEdit) and getKeyState('lctrl') and down then
			pasteEdit = guiCreateEdit(0,0,0,0,'',false)
			pasteEdit:setAlpha(0)
			pasteEdit:focus()
		else
			if isElement(pasteEdit) and key ~= 'v' then
				pasteEdit:destroy()
			end
		end		
	end
end

setmetatable(Input, {__call = function(_, ...) return Input.new(...) end})