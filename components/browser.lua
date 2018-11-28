Browser = Class('Browser')


function Browser.new(x, y, w, h, isLocal, isTransparent)
	local self = inherit(Component.new('Browser', x, y, w, h), Browser)
	self.browser = createBrowser(w, h, isLocal or false, isTransparent or false)
	self.volume = 1
	self.full = false

	local function onCreated()
		self:emit('created', self)
	end

	local function onReady()
		self:emit('documentReady', self)
	end

	self:on('destroy', function()
		removeEventHandler("onClientBrowserCreated", self.browser, onCreated)
		removeEventHandler("onClientBrowserDocumentReady", self.browser, onReady)
		self.browser:destroy()
	end)

	addEventHandler("onClientBrowserCreated", self.browser, onCreated)
	addEventHandler("onClientBrowserDocumentReady", self.browser, onReady)
	
	return self
end

function Browser:loadURL(url)
	self.browser:loadURL(url)
end

function Browser:getSource(callback)
	return self.browser:getSource(callback)
end

function Browser:resize(w, h)
	self.w = tonumber(w) and w or self.w
	self.h = tonumber(h) and h or self.h
	resizeBrowser(self.browser, w, h)
end

function Browser:setVolume(vol)
	self.browser:setVolume(vol)
	self.volume = vol
end

function Browser:setFullscreen(full)
	self.full = full
	if full then
		local sw, sh = guiGetScreenSize()
		if not isComponent(self.pane) then
			self.pane = Pane(0,0,sw,sh)
			Image(sw-45, sh-45,45,45,'./img/fullscreen.png',true)
				:on('mouseup', function()
					self:setFullscreen(false)
				end)
				:setParent(self.pane)
		end
		self.ow = self.w
		self.oh = self.h
		self:resize(sw, sh)
	else
		if isComponent(self.pane) then
			self.pane:destroy()
			self:resize(self.ow, self.oh)
		end
	end
end

function Browser:draw()
	if self.full then
		dxDrawImage(0, 0, self.w, self.h, self.browser, 0, 0, 0, tocolor(255, 255, 255, 255), true)
	else
		dxDrawImage(self.x, self.y, self.w, self.h, self.browser, 0, 0, 0, tocolor(255, 255, 255, 255), false)
	end

	if isElement(self.browser) then
		self.browser:setVolume(self.volume)
	end
end

setmetatable(Browser, {__call = function(_, ...) return Browser.new(...) end})