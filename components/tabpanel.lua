TabPanel = Class('TabPanel')
local _Tab = {}


function TabPanel.new(x, y, w, h)
	local self = inherit(Component.new('tabpanel', x, y, w, h), TabPanel)
	self.tabs = {}
	self.activeTab = nil
	self.topH = 30
	return self
end

function TabPanel:draw()
	dxDrawRectangle(self.x, self.y, self.w, self.h, tocolor(0,0,0,75))	

	local activeTab = self.activeTab
	if activeTab then
		activeTab:setVisible(true)
		activeTab.button.color = tocolor(55,55,255,255)

		if #activeTab.children == 0 then
			dxDrawText("This tab is empty!", self.x, self.y + self.topH, self.x + self.w, self.y + self.h - self.topH, tocolor(255,255,255), 2, 'default', 'center', 'center')
		end

		local offx = 0

		for i=1, #self.tabs do
			local tab = self.tabs[i]

			if tab ~= activeTab then
				tab:setVisible(false)
			end			

			tab.button.value = tab.value
			tab.button.ox = offx
			tab.button.w = self.w/#self.tabs

			offx = offx + tab.button.w
		end
	end
end

function TabPanel:addTab(name)
	local tab = _Tab.new(0, 0, self.w, self.h, name, self)
	table.insert(self.tabs, tab)

	if #self.tabs == 1 then
		self.activeTab = tab
	end

	return tab
end

function TabPanel:getTabByName(name)
	for i=1, #self.tabs do
		if self.tabs[i].value == name then
			return self.tabs[i]
		end
	end
	return false
end

function TabPanel:setActiveTab(tab)
	self.activeTab.button.color = tocolor(55,55,165,255)
	self.activeTab = tab
end

setmetatable(TabPanel, {__call = function(_, ...) return TabPanel.new(...) end})


function _Tab.new(x, y, w, h, value, parent)
	local self = inherit(Component.new('tabpanel:tab', x, parent.topH + y, w, h - parent.topH), _Tab)
	self.value = value

	self.button = Button(0, 0, parent.w, parent.topH, value)
		:setParent(parent)
		:on('mouseup', function()
			parent:setActiveTab(self)
		end)

	self:on('destroy', function()
		for i=1, #parent.tabs do
			if parent.tabs[i] == self then
				table.remove(parent.tabs, i)
				self.button:destroy()
			end
		end
	end)

	self:setParent(parent)
	self:setVisible(false)

	return self
end