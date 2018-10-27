Label = {}
Label.__index = Label


function Label.new(x, y, w, h, value, scale, color, shadowed, font, alignleft, aligntop)
	local self = setmetatable(Component.new('label', x, y, w, h), Label)
	self.value = value or ''
	self.scale = scale or 1
	self.color = color or tocolor(255,255,255,255)
	self.bgVisible = false
	self.bgColor = tocolor(0,0,0,200)
	self.shadow = shadowed or false
	self.font = font or 'default'
	self.alignleft = alignleft or 'left'
	self.aligntop = aligntop or 'top'
	return self
end

function Label:draw()
	if (self.bgVisible) then
		dxDrawRectangle(self.x, self.y, self.w, self.h, self.bgColor)
	end
	if (self.shadow) then
		dxDrawText(self.value, self.x + 1, self.y + 1, self.x + self.w + 1, self.y + self.h + 1, tocolor(0,0,0,255), self.scale, self.font, self.alignleft, self.aligntop, true)
	end
	dxDrawText(self.value, self.x, self.y, self.x + self.w, self.y + self.h, self.color, self.scale, self.font, self.alignleft, self.aligntop, true)
end

setmetatable(Label, {__call = function(_, ...) return Label.new(...) end})


-- function dxCreateFramedText(text, left, top, width, height, color, scale, font, alignX, alignY, clip, wordBreak, postGUI)
-- 	local self = {}
-- 	local rt = dxCreateRenderTarget(width, height, true)

-- 	self.draw = function(x, y, w, h)
-- 		dxDrawImage(left, top, width, height, rt)
-- 	end

-- 	self.update = function()
-- 		dxSetRenderTarget(rt, true)
-- 		dxDrawText(text, 1, 1, width + 1, height + 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI)
-- 		dxDrawText(text, 1, -1, width + 1, height - 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI)
-- 		dxDrawText(text, -1, 1, width - 1, height + 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI)
-- 		dxDrawText(text, 1, 1, width - 1, height - 1, tocolor(0, 0, 0), scale, font, alignX, alignY, clip, wordBreak, postGUI)
-- 		dxDrawText(text, 0, 0, width, height, color, scale, font, alignX, alignY, clip, wordBreak, postGUI)
-- 		dxSetRenderTarget()
-- 	end

-- 	self.setText = function(v)
-- 		text = v
-- 		self.update()
-- 	end

-- 	self.setColor = function(v)
-- 		color = v
-- 		self.update()
-- 	end

-- 	self.update()

-- 	return self
-- end


-- local msg1 = dxCreateFramedText("Hello there",222,300,520,140,tocolor(0,255,0),3,'default','left','top',false,false,false)
-- local msg2 = dxCreateFramedText("How are you?",222,400,520,140,tocolor(0,255,0),3,'default','left','top',false,false,false)

-- addEventHandler('onClientRender', root, function()
--    msg1.draw()
--    msg2.draw()
-- end)

-- msg2.setColor(tocolor(0,255,255))

-- addCommandHandler('c', function() msg1.setColor(tocolor(255,99,0)) end)
