-- Global Utils
local sw, sh = guiGetScreenSize()
mouseX, mouseY = false, false
screenW, screenH = guiGetScreenSize()

function globalRender()
	-- maybe run this only when a gui is focused
	mouseX, mouseY = getMouse()
	mouseDown = mouseX and getKeyState("mouse1")
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	addEventHandler("onClientRender", root, globalRender)
end)

function inherit(self, class)
	for k, v in pairs(class) do
		if k ~= 'new' and type(v) == 'function' then
			self[k] = v
		end
	end
	return self
end

function table.removeByValue(t, v)
	for i=#t, 1, -1 do
		if (t[i] == v) then
			return table.remove(t, i)
		end
	end
	return false
end

function table.copy(t)
	local new = {}
	for k,v in pairs(t) do
		if (type(v) == 'table') then
			v = table.copy(v)
		end
		new[k] = v
	end
	return new
end

function focus(index)
	local comp = components[index]
	if comp then
		comp:focus()
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

function assert(statement, message, level)
	local funcName = debug.getinfo(2, 'n').name or 'unknown'
	message = message or 'assertion failed!'
	level = level or 3
	if not statement then
		error('['..funcName..'] '..message, level)
	end
end

function check(pattern, arg, level)
	if type(pattern) ~= 'string' then check('s', pattern) end
	local types = {s = "string", n = "number", b = "boolean", f = "function", t = "table", u = "userdata"}
	for i=1, #pattern do
		local c = pattern:sub(i,i)
		local t = #arg > 0 and type(arg[i]) or nil
		if t ~= types[c] then
			local msg = "bad argument #%s in '%s' (%s expected, got %s)"
			level = level or 3
			local fname =  debug.getinfo(2, "n").name or '?'
			error(msg:format(i, fname, types[c], tostring(t)), level)
		end
	end
end