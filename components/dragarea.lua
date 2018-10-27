DragArea = {}
DragArea.__index = DragArea


function DragArea.new(x, y, w, h)
	local self
	if (not x) then
		self = setmetatable(Component.new("dragarea", 0, 0, 0, 0), DragArea)
	else
		self = setmetatable(Component.new("dragarea", x, y, w, h), DragArea)
	end
	self.auto = x and false or true
	self.dragging = false
	self.show = false
	
	self.pmx, self.pmy = 0, 0

	return self
end

function DragArea:draw()
	local parent = self.parent

	if not parent then return end

	local w, h = self.w, self.h
	local fs

	if (parent.type == "image") then
		if (parent:getFitMode() == "nostretch") then
			fs = parent:getFitSize()
			w = fs.w
			h = fs.h
		else
			self.w = parent.w
			self.h = parent.h
		end
	end

	if (self.auto and fs) then
		self.w = fs.w
		self.h = fs.h
	else
		if (not fs) then
			w = parent.w
			h = parent.h
		end
	end

	local pmx, pmy = self.pmx, self.pmy

	local mo = parent.focused and isMouseOverPos(self.x, self.y, self.w, self.h)

	if (pmx and mouseX and self.mouseDown and mo or mouseX and self.mouseDown and self.dragging) then
		local children = self.children

		for k,v in pairs(children) do
			if v.mouseDown then
				self.dragging = false
				return
			end
		end

		local parentParent = parent.parent

		if (parentParent) then
			parent.ox = constrain(parent.ox + (mouseX - pmx), 0, parentParent.w - w)
			parent.oy = constrain(parent.oy + (mouseY - pmy), 0, parentParent.h - h)
		else
			parent.x = parent.x + (mouseX - pmx)
			parent.y = parent.y + (mouseY - pmy)
		end
		self.dragging = true
	else
		self.dragging = false
	end

	self.pmx, self.pmy = mouseX, mouseY

	if (self.show) then
		dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(55,55,55,200))
	end
end

setmetatable(DragArea, {__call = function(_, ...) return DragArea.new(...) end})