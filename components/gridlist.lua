Gridlist = Class('Gridlist')


function Gridlist.new(x, y, w, h)
	local self = inherit(Component.new('gridlist', x, y, w, h), Gridlist)
	self.titleh = 25
	self.columns = {}
	self.items = {}
	self.itemh = 45
	self.itemSpacing = 2
	self.maxItems = 0
	self.sp = 1
	self.ep = nil
	self.selectedItem = 0
	self.rt = DxRenderTarget(self.w, self.h, true)
	self.rtUpdated = false
	self.scrollbarWidth = 15
	self.paddingLeft = 6
	self.scrollbarVisible = true
	self.textSize = 1.3
	self.titleSpacing = 27
	self.autoSizeColumns = true
	self.scrollbar = Scrollbar(self.w-self.scrollbarWidth, 0, self.scrollbarWidth, h):setParent(self)

	self.scrollbar:on('change', function(pos)
		if self.scrollbar.mouseDown then
			self.sp = math.ceil(pos)
			self.rtUpdated = false
		end
	end)

	self:_calculateScrollbar()

	return self
end

local function updateRT(self)
	dxSetRenderTarget(self.rt, true)
	if self.autoSizeColumns then
		self:fitColumnsToItems()
	end
	self:drawItems()
	dxSetRenderTarget()
end

local function parseItemValues(self, values)
	values = type(values) == 'table' and values or {values}
	local parsed = {}
	for i=1, #values do
		local val = {}
		val.value = tostring(values[i])
		val.width = dxGetTextWidth(val.value, self.textSize)

		if self.columns[i].checkThumbnails then
			if not fileExists(tostring(val.value)) then
				val.origValue = values[i]
				val.value = 'img/broken.png'
			end
			val.width = self.itemh
		end

		table.insert(parsed, val)
	end
	return parsed
end

local function getMaxItems(self)
	return math.floor((self.h-self.titleh)/(self.itemh+self.itemSpacing))
end

function Gridlist:_calculateScrollbar()
	self.maxItems = getMaxItems(self)
	self.scrollbar:setMinMax(1, (#self.items-self.maxItems+1))

	local h = self.h * (self.h / ((#self.items + 1) * self.itemh))
	self.scrollbar.enabled = h <= self.h
	self.scrollbar:setThumbHeight(math.min(self.h, h))
end

function Gridlist:refreshItems(itemIndex)
	if itemIndex then
		local vals = {}
		for k,v in pairs(self.items[itemIndex].values) do
			if v.origValue then
				table.insert(vals, v.origValue)
			else
				table.insert(vals, v.value)
			end
		end
		self.items[itemIndex].values = parseItemValues(self, vals)
	else
		for i=1, #self.items do
			local vals = {}
			for k,v in pairs(self.items[i].values) do
				if v.origValue then
					table.insert(vals, v.origValue)
				else
					table.insert(vals, v.value)
				end
			end
			self.items[i].values = parseItemValues(self, vals)
		end
	end
end

function Gridlist:addColumn(title, width)
	check('s', {title})

	local col = {
		fixedSize = not not width,
		value = tostring(title),
		titleWidth = dxGetTextWidth(title, self.textSize),
		checkThumbnails = false
	}
	col.width = width or col.titleWidth
	table.insert(self.columns, col)
	return col
end

function Gridlist:removeColumn(colIndex)
	check('n', {colIndex})
	table.remove(self.columns, colIndex)
	updateRT()
end

function Gridlist:setColumnWidth(colIndex, width)
	check('nn', {colIndex, width})
	local col = self.columns[colIndex]
	col.width = width
	col.fixedSize = true
end

function Gridlist:setColumnCheckThumbnails(colIndex, state)
	check('b', {state})

	self.columns[colIndex].checkThumbnails = state
	if state then
		for i=1, #self.items do
			local val = self.items[i].values[colIndex].value
			self.items[i].values[colIndex] = parseItemValues(self, val)[1]
		end
	end
end

function Gridlist:fitColumnsToItems()
	for i=1, #self.columns do
		local col = self.columns[i]

		if not col.fixedSize then
			col.width = col.titleWidth + self.titleSpacing

			for j=1, #self.items do
				local itemVal = self.items[j].values[i]
				if itemVal then
					local width = itemVal.width + self.titleSpacing
					col.width = math.max(width, col.width)
				end
			end
		end
	end
end

function Gridlist:addItem(values, onClick)
	assert(#self.columns ~= 0, "the gridlist doesn't have any columns")

	local item = {
		values = parseItemValues(self, values),
		onClick = type(onClick) == 'function' and onClick or false
	}

	table.insert(self.items, item)

	self:_calculateScrollbar()

	updateRT(self)
	return item
end

function Gridlist:removeItem(itemIndex)
	check('n', {itemIndex})
	table.remove(self.items, itemIndex)

	self:_calculateScrollbar()

	if self.sp > (#self.items-self.maxItems-1) then
		self:setScrollPosition(#self.items)
	end

	updateRT(self)
end

function Gridlist:getItemsValues()
	local items = {}
	for _, item in ipairs(self.items) do
		local vals = {}
		for i, value in ipairs(item.values) do
			table.insert(vals, value.value)
		end
		table.insert(items, vals)
	end
	return items
end

function Gridlist:getSelectedItem()
	return self.selectedItem
end

function Gridlist:setSelectedItem(index)
	if self.items[index] then
		self.selectedItem = index
		if self.items[index].onClick then
			self.items[index].onClick(index)
		end
		updateRT(self)
	end
end

function Gridlist:selectNextItem()
	local itemIndex = self.selectedItem == #self.items and 1 or self.selectedItem + 1
	self:setSelectedItem(itemIndex)
end

function Gridlist:selectPrevItem()
	local itemIndex = self.selectedItem == 1 and #self.items or self.selectedItem - 1
	self:setSelectedItem(itemIndex)
end

function Gridlist:getItemValue(itemIndex, colIndex)
	check('n', {itemIndex})
	local vals = self.items[itemIndex].values
	return type(colIndex) == 'number' and vals[colIndex] or vals
end

function Gridlist:setItemValue(itemIndex, colIndex, value)
	check('nns', {itemIndex, colIndex, value})
	self.items[itemIndex].values[colIndex] = parseItemValues(self, value)[1]
end

function Gridlist:getItemByIndex(itemIndex)
	check('n', {itemIndex})
	return self.items[itemIndex]
end

function Gridlist:getItemCount()
	return #self.items
end

function Gridlist:clear()
	self.items = {}
	self.selectedItem = 0
	self.sp = 1
	updateRT(self)
end

function Gridlist:setItemHeight(val)
	check('n', {val})
	self.itemh = math.max(1, val)
	updateRT(self)
end

function Gridlist:setScrollPosition(pos)
	check('n', {pos})
	self.sp = math.max(1, math.min(#self.items - self.maxItems + 1, pos))
	self.scrollbar:setScrollPosition(self.sp)
	updateRT(self)
end

function Gridlist:sort(colIndex, reverse)
	check('n', {colIndex})
	local col = self.columns[colIndex]

	if not col then return end

	table.sort(self.items, function(a, b)
		a = a.values[colIndex].value
		b = b.values[colIndex].value
		local anum = tonumber(a)
		local bnum = tonumber(b)

		if reverse then
			if anum and bnum then
				return anum > bnum
			else
				return a > b
			end
		end

		if anum and bnum then
			return anum < bnum
		else
			return a < b
		end
	end)

	updateRT(self)
end

function Gridlist:draw()
	if not self.visible then return end

	self.mouseOver = mouseX and isMouseOverPos(self.x, self.y, self.w, self.h)
	self.maxItems = getMaxItems(self)

	dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(0,0,0,150))

	if not self.rtUpdated or self.mouseOver and self.focused then
		updateRT(self) -- draw items onto the render target
		self.rtUpdated = true
	end
	
	dxDrawImage(self.x, self.y, self.w, self.h, self.rt)
end

function Gridlist:drawItems()
	if not self.maxItems then return end
	
	local itemCount = #self.items
	self.ep = itemCount < self.maxItems and itemCount or self.sp + self.maxItems - 1

	local paddingX = self.paddingLeft
	local yOff = self.titleh
	local xOff = paddingX

	local columnCount = #self.columns

	-- column titles
	for i=1, columnCount do
		local col = self.columns[i]
		
		if self.titleh > 0 then
			dxDrawText(col.value, xOff, 0, xOff + col.width, self.titleh, tocolor(255,255,220), self.textSize, "default-bold", "left", "center")
		end

		xOff = xOff + col.width
	end

	-- rows
	for i=self.sp, self.ep do
		local xOff = 0

		local item = self.items[i]

		if not item then
			return
		end

		local clickArea = {
			x = self.x,
			y = self.y + yOff,
			w = self.w - self.scrollbarWidth,
			h = self.itemh
		}

		-- styles (temporary, eventually will be replaced with global styles)
		local mo = self.focused and isMouseOverPos(clickArea.x, clickArea.y, clickArea.w, clickArea.h)
		local textColor = (self.selectedItem == i and tocolor(255,255,255)) or (mo and tocolor(55,55,255,255)) or item.color or tocolor(255,255,255)
		local bgColor = (self.selectedItem == i and tocolor(55,55,255,255)) or (mo and tocolor(15,15,15,255)) or item.bgColor or tocolor(23,23,23,255)

		-- item background
		dxDrawImage(xOff, yOff, clickArea.w, self.itemh, "./img/button.png", 0, 0, 0, bgColor)

		item.clickArea = clickArea

		for j=1, columnCount do
			local col = self.columns[j]
			local itemVal = item.values[j]
			local val = itemVal and itemVal.value

			if val then
				if col.checkThumbnails then
					dxDrawImage(xOff + paddingX, yOff, self.itemh, self.itemh, val, 0, 0, 0)
				else
					dxDrawText(val, xOff + paddingX, yOff, xOff + paddingX + col.width, yOff + self.itemh, textColor, self.textSize, 'arial', "left", "center", true, false, false, false, false)
				end
			end

			xOff = xOff + col.width
		end

		yOff = yOff + self.itemh + self.itemSpacing
	end
end

function Gridlist:onKey(key, down)
	if not self.mouseOver then return end
	
	self.rtUpdated = false

	if key == 'mouse_wheel_down' then
		if self.sp <= #self.items - self.maxItems then
			self.sp = self.sp + 1
			self.scrollbar:setScrollPosition(self.sp)
		end

	elseif key == 'mouse_wheel_up' then
		if self.sp > 1 then
			self.sp = self.sp - 1
			self.scrollbar:setScrollPosition(self.sp)
		end

	elseif key == 'mouse1' and not down and not self.scrollbar.mouseDown then
		for i=self.sp, self.ep do
			local item = self.items[i]
			if self.mouseDown and isMouseOverPos(item.clickArea.x, item.clickArea.y, item.clickArea.w, item.clickArea.h) then
				self:setSelectedItem(i)
			end
		end

	elseif key == 'arrow_d' and down then
		self:selectNextItem()

	elseif key == 'arrow_u' and down then
		self:selectPrevItem()
	end
end

setmetatable(Gridlist, {__call = function(_, ...) return Gridlist.new(...) end})