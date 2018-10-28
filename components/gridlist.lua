Gridlist = {}
Gridlist.__index = Gridlist


function Gridlist.new(x, y, w, h)
	local self = setmetatable(Component.new("gridlist", x, y, w, h), Gridlist)
	self.titleh = 25
	self.columns = {}
	self.items = {}
	self.itemh = 45
	self.itemSpace = 2
	self.maxItems = nil
	self.sp = 1
	self.ep = nil
	self.selectedItem = 0
	self.rt = DxRenderTarget(self.w, self.h, true)
	self.rt_updated = false
	self.scrollbarWidth = 15
	return self
end

local function updateRT(self)
	dxSetRenderTarget(self.rt, true)
	self:drawItems()
	dxSetRenderTarget()
end

local function resizeColumn(column, val)
	if (column.autosize) then
		local textWidth = type(val) == "number" and val or dxGetTextWidth(val, 1.5)
		if (textWidth > column.width) then
			column.width = textWidth + 10
		end
	end
end

function Gridlist:addColumn(val, width)
	local column = {}

	column.autosize = not width
	column.val = val
	column.width = width or dxGetTextWidth(val, 1.5) + 10
	--column.btn = dx.button(val, 0, 0, width, self.titleh)
	--column.btn.onclick = function() self.sort(val) end

	table.insert(self.columns, column)
	return column
end

function Gridlist:removeColumn(i)
	table.remove(self.columns, i)
end

function Gridlist:addItem(...)
	local arg1, arg2 = unpack(arg)
	local val = arg1
	local imgColIndex = type(arg2) == 'number' and arg2
	local callback = type(arg[#arg]) == 'function' and arg[#arg]

	local values = type(val) ~= "table" and {val} or val
	if (imgColIndex) then
		if not fileExists(values[imgColIndex]) then
			error("file " .. values[imgColIndex] .. " doesn't exist", 2)
		end
	end

	if #self.columns == 0 then
		return
	end

	local item = {}
	item.values = values
	item.onClick = callback
	item.imgColIndex = imgColIndex

	table.insert(self.items, item)

	updateRT(self)

	return item
end

function Gridlist:removeItem(i)
	table.remove(self.items, i)
	
	if #self.items == 0 then
		self.selectedItem = 0
	else
		self.sp = math.max(1, self.sp - 1)
	end

	updateRT(self)
end

function Gridlist:clear()
	self.items = {}
	self.selectedItem = 0
	self.sp = 1
	updateRT(self)
end

function Gridlist:sort(_type) -- this func needs to be redone, currently doesn't support sorting by column
	local f = function(a, b) return a < b end

	if (_type) then
		f = function(a, b)
			if (a.data[_type] and b.data[_type]) then
				return a.data[_type] > b.data[_type]
			else
				error("can't sort by that key (not found)", 4)
			end
		end
	end

	table.sort(self.items, f)
	updateRT(self)
end

function Gridlist:draw()
	if (not self.visible) then return end

	self.mouseOver = mouseX and isMouseOverPos(self.x, self.y, self.w, self.h)
	self.maxItems = math.floor((self.h-self.titleh)/(self.itemh+self.itemSpace))

	dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(0,0,0,150))

	if (not self.rt_updated or self.mouseOver) then
		updateRT(self) -- draw items onto rt
		self.rt_updated = true
	end
	
	dxDrawImage(self.x, self.y, self.w, self.h, self.rt)

	self:drawScrollBar()
end

function Gridlist:drawScrollBar()
	if #self.items > self.maxItems then
		local shaftw = self.scrollbarWidth
		local shafth = self.h

		local thumbw = self.scrollbarWidth
		local thumbh = (shafth/(#self.items-self.maxItems+1))

		local thumbPos = thumbh * (self.sp - 1)

		-- shaft
		dxDrawRectangle(self.x + self.w - shaftw, self.y, shaftw, shafth, tocolor(66,66,66,200))
		-- thumb
		dxDrawRectangle(self.x + self.w - thumbw, self.y + thumbPos, thumbw, thumbh, tocolor(55,55,255,255))
	end
end

function Gridlist:drawItems()
	if (not self.maxItems) then return end
	self.ep = #self.items < self.maxItems and #self.items or self.sp + self.maxItems - 1

	local xOff = 0

	for j=1, #self.columns do
		local yOff = self.titleh
		local col = self.columns[j]

		-- column title
		if (self.titleh > 0) then
			dxDrawText(col.val, xOff, 0, xOff + col.width, self.titleh, tocolor(255,255,220), 1.5, "default", "left", "center")
		end

		for i=self.sp, self.ep do
			local item = self.items[i]
			local val = item.values[j]

			-- item click pos
			item.pos = {
				x = self.x,
				y = self.y + yOff,
				w = self.w - self.scrollbarWidth,
				h = self.itemh
			}

			-- item styling
			local style = self.style
			local mo = self.focused and isMouseOverPos(item.pos.x, item.pos.y, item.pos.w, item.pos.h)
			local textFont = "default"
			local textSize = 1.25
			local textColor = (self.selectedItem == i and tocolor(200,70,70)) or (mo and tocolor(55,155,55)) or item.color or tocolor(255,255,255)
			local bgColor = (self.selectedItem == i and tocolor(33,33,33,222)) or (mo and tocolor(255,255,255,200)) or item.bgColor or tocolor(0,111,200,200)

			-- item bg
			if (j == 1) then
				--dxDrawRectangle(0, yOff, self.w, self.itemh, bgColor)
				dxDrawImage(xOff, yOff, item.pos.w, self.itemh, "./img/button.png", 0, 0, 0, tocolor(25,25,25))
			end

			if (val) then
				-- item image
				if (item.imgColIndex and item.imgColIndex == j) then
					resizeColumn(col, self.itemh)

					dxDrawImage(xOff, yOff, self.itemh, self.itemh, val, 0, 0, 0)
				end

				-- item text
				if (item.imgColIndex ~= j) then
					resizeColumn(col, val)

					-- if (style.itemText.shadow) then
					-- 	dxDrawText(val, xOff+1, yOff+1, xOff + col.width+1, yOff + self.itemh+1, tocolor(0, 0, 0, 255), textSize, textFont, "left", "center", true, false, false, false, false)
					-- end
				
					dxDrawText(val, xOff, yOff, xOff + col.width, yOff + self.itemh, textColor, textSize, textFont, "left", "center", true, false, false, false, false)
				end
			end

			yOff = yOff + self.itemh + self.itemSpace
		end
		
		xOff = xOff + col.width + 10
	end
end

function Gridlist:onKey(key, down)
	if (not self.mouseOver or not self.focused) then return end
	
	self.updated = false

	if (key == "mouse_wheel_down") then
		if (self.sp <= #self.items - self.maxItems) then
			self.sp = self.sp + 1
		end

	elseif (key == "mouse_wheel_up") then
		if (self.sp > 1) then
			self.sp = self.sp - 1
		end

	elseif (key == 'mouse1' and not down) then
		for i=self.sp, self.ep do
			local item = self.items[i]

			if (self.mouseDown and isMouseOverPos(item.pos.x, item.pos.y, item.pos.w, item.pos.h)) then
				self.selectedItem = i
				if item.onClick then
					item.onClick()
				end
			end
		end
	end
end

setmetatable(Gridlist, {__call = function(_, ...) return Gridlist.new(...) end})