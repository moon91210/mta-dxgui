components = {}

Component = {}

function Component.new(typ, x, y, w, h)
	check('nnnn', {x, y, w, h}, 5)
	local self = inherit({}, Component)
	self.ox = x
	self.oy = y
	self.x = x
	self.y = y
	self.w = w
	self.h = h
	self.offx = 0
	self.offy = 0
	self.type = typ
	self.value = ''
	self.children = {}
	self.parent = nil
	self.visible = true
	self.enabled = true
	self.focused = false
	self.mouseOver = false
	self.mouseDown = false
	self.dragArea = nil
	self.tooltip = {}

	Emitter.new(self)

	table.insert(components, 1, self)

	return self
end

function Component:update()
	if not self.visible then return end

	if type(self.value) ~= 'string' then
		self.value = tostring(self.value)
	end

	local parent = self.parent
	
	if parent then
		self.x = parent.x + self.ox + parent.offx
		self.y = parent.y + self.oy + parent.offy
	end
	
	if self.draw then
		self:draw()
		self:emit('update')
	end
	
	for i=#self.children, 1, -1 do
		self.children[i]:update()
	end

	if not self.enabled then
		dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(0,0,0,200))
	end

	self.mouseOver = (self.focused or not parent) and isMouseOverPos(self.x, self.y, self.w, self.h)

	self:drawTooltip()
end

function Component:drawTooltip()
	if not self.tooltip.value then return end
	if not self.mouseOver then return end
	if not self:isOnTop() then return end

	local d = self.tooltip
	local val = d.value
	local tw, th = d.tw, d.th
	local pad = d.pad
	local offset = d.offset
	local fontSize = d.fontSize
	local font = d.font
	local mx, my = mouseX + offset, mouseY + offset

	dxDrawRectangle(mx, my, tw + pad*4, th + pad*2, tocolor(0,0,0,215), true)
	dxDrawText(val, mx + pad*2, my + pad, tw - pad*2, th - pad*2, tocolor(255,255,255), fontSize, font, 'left', 'top', false, false, true)
end

function Component:setTooltip(data)
	check('t', {data})
	if type(data.value) ~= 'string' then return end
	local d = self.tooltip
	d.value = data.value
	d.fontSize = data.fontSize or d.fontSize or 1.5
	d.pad = data.pad or d.pad or 3
	d.offset = data.offset or d.offset or 10
	d.font = data.font or d.font or 'default'
	d.tw = dxGetTextWidth(d.value, d.fontSize, d.font)
	d.th = dxGetFontHeight(d.fontSize, d.font)
end

function Component:focus()
	if not self.visible then return end

	for i=1, #components do
		if self ~= components[i] then
			components[i].focused = false
		end
	end

	for i=1, #self.children do
		self.children[i]:focus()
	end

	self.focused = true

	return self
end

function Component:destroy()
	local children = self.children
	for i=#children, 1, -1 do
		children[i]:destroy()
	end

	local parent = self.parent
	if parent then
		table.removeByValue(parent.children, self)
	else
		table.removeByValue(components, self)
	end

	self:emit('destroy', self)

	collectgarbage()
end

function Component:setParent(parent)
	assert(isComponent(parent), "the parent doesn't exist or was destroyed")

	if self.parent then
		self:removeParent()
	end

	table.removeByValue(components, self)
	table.insert(parent.children, self)
	self.parent = parent
	return self
end

function Component:addChild(...)
	local children = isComponent(arg[1]) and arg
		or type(arg[1]) == 'table' and arg[1]

	if children then
		for i=1, #children do
			if isComponent(children[i]) then
				children[i]:setParent(self)
			end
		end
	end

	return self
end

function Component:getChildren(typ)
	if typ then
		check('s', {typ})
		local children = {}
		for i=1, #self.children do
			local child = self.children[i]
			if child.type == typ then
				table.insert(children, child)
			end
		end
		return children
	else
		return self.children
	end
end

function Component:removeParent()
	if self.parent then
		table.removeByValue(self.parent.children, self)
		self.parent = nil
		table.insert(components, self)
	end
	return self
end

function Component:setOnTop()
	local comps = self.parent and self.parent.children or components
	if comps[1] ~= self then
		table.removeByValue(comps, self)
		table.insert(comps, 1, self)
	end
	self:focus()
	return self
end

function Component:isOnTop()
	local first = components[1]
	if first == self.parent or first == self then
		return true
	end
	return false
end

function Component:setToBack()
	local comps = self.parent and self.parent.children or components
	if comps[#comps] ~= self then
		table.removeByValue(comps, self)
		table.insert(comps, self)
	end
	return self
end

function Component:setDraggable(state)
	check('b', {state})
	if state then
		if not isComponent(self.dragArea, 'dragarea') then
			self.dragArea = DragArea():setParent(self)
		end
	else
		if isComponent(self.dragArea, 'dragarea') then
			self.dragArea:destroy()
		end
	end
	return self
end

function Component:getEnabled()
	return self.enabled
end

function Component:setEnabled(state)
	self.enabled = state
	return self
end

function Component:getPosition()
	return self.x, self.y
end

function Component:setPosition(x, y)
	x = x or self.ox
	y = y or self.oy
	self.ox, self.oy = x, y
	self.x, self.y = x, y
	return self
end

function Component:getSize()
	return self.w, self.h
end

function Component:setSize(w, h)
	self.w = w or self.w
	self.h = h or self.h
	return self
end

function Component:getVisible()
	return self.visible
end

function Component:setVisible(v)
	self.visible = v
	return self
end

function Component:hide()
	self.visible = false
	return self
end

function Component:show()
	self.visible = true
	return self
end

function Component:getValue()
	return self.value
end

function Component:setValue(v)
	self.value = tostring(v)
	return self
end

function Component:align(state)
	if self.parent then
		if state == 'center' or state == 'centerX' then
			self.ox = self.parent.w/2-self.w/2
		end
		if state == 'center' or state == 'centerY' then
			self.oy = self.parent.h/2-self.h/2
		end
	else
		if state == 'center' or state == 'centerX' then
			self.x = screenWidth/2-self.w/2
		end
		if state == 'center' or state == 'centerY' then
			self.y = screenHeight/2-self.h/2
		end
	end
	return self
end

function Component:center()
	self:align('center')
	return self
end

function Component:drawBorders(size, color)
	size = size or 2
	color = color or tocolor(255,55,55,200)
	dxDrawLine(self.x-size, self.y-size/2, self.x+size + self.w, self.y-size/2, color, size)--top
	dxDrawLine(self.x-size, self.y+size/2 + self.h, self.x+size + self.w, self.y+size/2 + self.h, color, size)--bottom
	dxDrawLine(self.x-size/2, self.y, self.x-size/2, self.y + self.h, color, size)--left
	dxDrawLine(self.x+size/2 + self.w, self.y, self.x+size/2 + self.w, self.y + self.h, color, size)--right
end