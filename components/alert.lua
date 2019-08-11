function Alert(message, callback, lockBackground)
	check('s', {message})

	local self

	local win = Window(0, 0, 500, 280, 'Alert')
		:setOnTop()

	if lockBackground then
		self = Pane(0, 0, screenWidth, screenHeight)
			:addChild(win)
	else
		self = win
	end

	win:align('center')
	
	win:once('close', function() self:destroy() end)
	win:once('destroy', function() focus(2) end)

	Label(130, 40, win.w*0.65, 30, message, 1.5, tocolor(255,255,255), true, 'sans', 'left', 'top')
		:setParent(win)

	Button(0, 170, 120, 40, 'OK')
		:setParent(win)
		:align('centerX')
		:once('mouseup', function()
			if type(callback) == 'function' then
				callback()
			end
			self:destroy()
		end)

	Image(35, 40, 65, 65, './img/sign-info-icon.png')
		:setParent(win)

	return self
end