addEventHandler('onClientRender', root, function()
	for i = #components, 1, -1 do
		components[i]:update()
	end
end)

addEventHandler('onClientClick', root, function(btn, state, mx, my)
	for i = 1, #components do
		local comp = components[i]
		local state = dxClickHandler(comp, btn, state, mx, my)
		if state then
			comp.focused = state
			return true
		end
	end
end)

addEventHandler('onClientKey', root, function(key, down)
	for i = 1, #components do
		local comp = components[i]
		comp.keyUsed = dxKeyHandler(components[i], key, down)
		if comp.keyUsed then
			return false
		end
	end
end)

function dxKeyHandler(self, key, down)
	if not self.visible and not self.focused and not self.enabled then return end

	for i=1, #self.children do
		if dxKeyHandler(self.children[i], key, down) then
			return true
		end
	end

	if self.onKey then
		self:onKey(key, down)
		return true
	end
end

function dxClickHandler(self, btn, state, mx, my)
	if not self or not self.visible or not self.enabled then return end

	local children = self.children

	for i=1, #children do
		if dxClickHandler(children[i], btn, state, mx, my) then
			return true
		end
	end

	local w, h = self.w, self.h
	-- exception for images with fitmode set to 'nostretch'
	if self.type == 'image' and self:getFitMode() == 'nostretch' and self:getPixels() then
		local fs = self:getFitSize()
		w, h = fs.w, fs.h
	end

	local mouseOver = isMouseOver(self, w, h)
	if state == 'down' then
		if mouseOver then
			self.mouseDown = true
			self:setOnTop()

			self:emit('mousedown', btn)
			self:emit('click', btn, state)

			if not self.parent then
				return true
			end
		end
	else
		if mouseOver and self.focused and self.mouseDown then
			self:emit('mouseup', btn)
			self:emit('click', btn, state)
			self.mouseDown = false
			return false
		end
		self.mouseDown = false
	end

	if self.onClick and self.focused then
		self:onClick(btn, state)
	end

	return false
end