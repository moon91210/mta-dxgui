function inherit(self, class)
	for k, v in pairs(class) do
		if type(v) == "function" then
			self[k] = v
		end
	end
	return self
end