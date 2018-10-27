addEventHandler("onClientRender", root, function()
	for i = #components, 1, -1 do
		components[i]:update()
	end
end)

addEventHandler("onClientClick", root, function(btn, state, mx, my)
	for i = 1, #components do
		local comp = components[i]
		comp.focused = dxClickHandler(comp, btn, state, mx, my)
		if (comp.focused) then
			return false
		end
	end
end)

addEventHandler("onClientKey", root, function(key, down)
	for i = 1, #components do
		local comp = components[i]
		comp.keyUsed = dxKeyHandler(components[i], key, down)
		if (comp.keyUsed) then
			return false
		end
	end
end)