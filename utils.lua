-- Global Utils
local sw, sh = guiGetScreenSize()
mouseX, mouseY = false, false

function globalRender()
	-- maybe run this only when a gui is focused
	mouseX, mouseY = getMouse()
	mouseDown = mouseX and getKeyState("mouse1")
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	addEventHandler("onClientRender", root, globalRender)
end)

--showCursor(true)

Table = {}

function Table.new(o)
	return setmetatable(o or {}, {__index = function(t, k) return table[k] end})
end

function table:removeByValue(v)
	for i=1, #self do
		if (self[i] == v) then
			self:remove(i)
		end
	end
	return false
end

function table:copy()
	local new = Array.new()
	for k,v in pairs(self) do
		if (type(v) == "table") then
			v = v:copy()
		end
		new[k] = v
	end
	return new
end

-- Handlers
function dxCallEvent(self, event, ...)
	local events = self.events
	for i=#events, 1, -1 do
		local evt = events[i]
		if evt.event == event then
			evt.callback(unpack(arg))
			if evt.once then
				table.remove(events, i)
			end
		end
	end
	return false
end

function check(pattern, arg, level)
	if type(pattern) ~= 'string' then check('s', pattern) end
	local types = {s = "string", n = "number", b = "boolean", f = "function", t = "table", u = "userdata"}
	for i=1, #pattern do
		local c = pattern:sub(i,i)
		local t = #arg > 0 and type(arg[i])
		if not t then error('got pattern but missing args') end
		if t ~= types[c] then error(("bad argument #%s to '%s' (%s expected, got %s)"):format(i, debug.getinfo(2, "n").name, types[c], tostring(t)), level or 3) end
	end
end

function isComponent(comp, typ)
	if type(comp) == 'table' and comp.type then
		if typ then
			return typ == comp.type
		end
		return true
	end
	return false
end

function dxKeyHandler(self, key, down)
	if (not self.visible) then return end

	for i=1, #self.children  do
		local child = self.children[i]
		if (dxKeyHandler(child, key, down)) then
			return true
		end
	end

	if(self.onKey) then
		self:onKey(key, down)
	end
end

function dxClickHandler(self, btn, state, mx, my)
	if (not self.visible) then return end

	local children = self.children

	for i=1, #children do
		if (dxClickHandler(children[i], btn, state, mx, my)) then
			return true
		end
	end

	-- exception for images with fitmode set to "nostretch"
	local w, h = self.w, self.h
	if (self.type == "image" and self:getFitMode() == "nostretch" and self:getPixels()) then
		local fs = self:getFitSize()
		w, h = fs.w, fs.h
	end

	local mouseOver = isMouseOver(self, w, h)
	
	if (self.onClick) then
		self:onClick(btn, state)
	end

	if (btn == "left") then
		if (state == "down")  then
			if (mouseOver) then
				self.mouseDown = true
				self:setOnTop()
				if (not self.parent) then
					return true
				end
			end
		else
			if (mouseOver and self.mouseDown) then
				if (self.focused) then
					dxCallEvent(self, "click", btn)
					self.mouseDown = false
					return true
				end
			end
			self.mouseDown = false
		end
	end

	return false
end

-- Global Methods
function isMouseOver(self, w, h)
	return mouseX and w and h and mouseX >= self.x and mouseX <= self.x + w and mouseY >= self.y and mouseY <= self.y + h
end

function isMouseOverPos(x, y, w, h)
	return mouseX and w and h and mouseX >= x and mouseX <= x + w and mouseY >= y and mouseY <= y + h
end

function getMouse()
	local mx, my = getCursorPosition()
	return mx and mx*sw, my and my*sh
end

function constrain(num, low, high)
	return (num >= low and num <= high and num) or (num < low and low) or (num > high and high)
end

function map(n, start1, stop1, start2, stop2)
	return ((n-start1)/(stop1-start1))*(stop2-start2)+start2
end