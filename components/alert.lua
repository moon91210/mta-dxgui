function Alert(message, callback)
	check('s', {message})

	local self = Window(0, 0, 500, 280, 'Message')
		:align('center')
		:setOnTop()
	
	self:once('close', function()
		self:destroy()
	end)

	Label(130, 40, self.w*0.65, 30, message, 1.5, tocolor(255,255,255), true, 'sans', 'left', 'top')
		:setParent(self)

	Button(0, 170, 120, 40, 'OK')
		:setParent(self)
		:align('centerX')
		:once('mouseup', function()
			if type(callback) == 'function' then
				callback()
			end
			self:destroy()
		end)

	Image(35, 40, 65, 65, './img/sign-info-icon.png')
		:setParent(self)

	return self
end