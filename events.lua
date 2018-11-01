addEventHandler('onClientRender', root, function()
	for i = #components, 1, -1 do
		components[i]:update()
	end
end)

addEventHandler('onClientClick', root, function(btn, state, mx, my)
	for i = 1, #components do
		local comp = components[i]
		comp.focused = dxClickHandler(comp, btn, state, mx, my)
		if (comp.focused) then
			return false
		end
	end
end)

addEventHandler('onClientKey', root, function(key, down)
	for i = 1, #components do
		local comp = components[i]
		comp.keyUsed = dxKeyHandler(components[i], key, down)
		if (comp.keyUsed) then
			return false
		end
	end
end)

function dxKeyHandler(self, key, down)
	if (not self.visible) then return end

	for i=1, #self.children do
		if (dxKeyHandler(self.children[i], key, down)) then
			return true
		end
	end

	if (self.onKey and self.focused) then
		self:onKey(key, down)
		return true
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

	local w, h = self.w, self.h
	-- exception for images with fitmode set to 'nostretch'
	if (self.type == 'image' and self:getFitMode() == 'nostretch' and self:getPixels()) then
		local fs = self:getFitSize()
		w, h = fs.w, fs.h
	end

	local mouseOver = isMouseOver(self, w, h)
	
	if (self.onClick and self.focused) then
		self:onClick(btn, state)
	end

	if (btn == 'left' or btn == 'middle') then
		if (state == 'down')  then
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
					self:emit('click', btn)
					self.mouseDown = false
					return true
				end
			end
			self.mouseDown = false
		end
	end

	return false
end