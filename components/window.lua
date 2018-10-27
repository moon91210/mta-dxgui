Window = {}
Window.__index = Window


function Window.new(x, y, w, h, value)
	local self = setmetatable(Component.new("window", x, y, w, h), Window)

	self.value = value or ""
	self.title_h = 30
	self.offy = self.title_h
	
	local dragArea = DragArea(0, -self.offy, self.w, self.title_h):setParent(self)

	self.closeBtn = Button.new(self.w - self.title_h, 3, self.title_h-3, self.title_h-5, "×")
		:setParent(dragArea)
		:on("click", function()
			self.visible = false
			dxCallEvent(self, "close")
		end)

	return self
end

function Window:draw()
	-- local cz = 10
	local color = self.focused and tocolor(20,20,20,235) or tocolor(8,8,8,235)
	-- dxDrawImage(self.x, self.y + self.title_h, cz, cz, "img/corner.png", 0,0,0, color)
	-- dxDrawImage(self.x + self.w - cz, self.y + self.title_h, cz, cz, "img/corner.png", 90,0,0, color)

	-- titlebar
	dxDrawRectangle(self.x, self.y, self.w, self.title_h, tocolor(0,0,0,245))
	-- main bg
	dxDrawRectangle(self.x, self.y + self.title_h, self.w, self.h - self.title_h, color)
	
	-- dxDrawRectangle(self.x + cz, self.y + self.h, self.w - cz*2, cz, color)
	
	-- dxDrawImage(self.x, self.y + self.h, cz, cz, "img/corner.png", -90,0,0, color)
	-- dxDrawImage(self.x + self.w - cz, self.y + self.h, cz, cz, "img/corner.png", 180,0,0, color)

	dxDrawText(self.value, self.x+2, self.y+2, self.x + self.w+2, self.y + self.title_h+2, tocolor(0,0,0,255), 1.5, "tahoma", "center", "center")
	dxDrawText(self.value, self.x, self.y, self.x + self.w, self.y + self.title_h, tocolor(225,225,225,255), 1.5, "tahoma", "center", "center")
end

function Window:drawBorders()
	local size = 2
	dxDrawLine(self.x, self.y, self.x + self.w, self.y, _, size)
	dxDrawLine(self.x, self.y + self.h, self.x + self.w, self.y + self.h, _, size)
	dxDrawLine(self.x, self.y, self.x, self.y + self.h, _, size)
	dxDrawLine(self.x + self.w, self.y, self.x + self.w, self.y + self.h, _, size)
end

setmetatable(Window, {__call = function(_, ...) return Window.new(...) end})