Emitter = {}


function Emitter.new(o)
	local self = inherit(o or {}, Emitter)
	self._on = {}
	self._once = {}
	return self
end

function Emitter:on(evname, callback)
	assert(type(evname) == 'string', 'arg1 not a string')
	assert(type(callback) == 'function', 'arg2 not a function')
	local evtbl = self._on[evname]
	if not evtbl then
		evtbl = {}
		self._on[evname] = evtbl
	end
	table.insert(evtbl, callback)
	return self
end

function Emitter:once(evname, callback)
	assert(type(evname) == 'string', 'arg1 not a string')
	assert(type(callback) == 'function', 'arg2 not a function')
	self._once[evname] = callback
	return self
end

function Emitter:off(evname, callback)
	local evtbl = self._on[evname]
	if evtbl then
		for i=1, #evtbl do
			if evtbl[i] == callback then
				return table.remove(evtbl, i)
			end
		end
	end
end

function Emitter:emit(evname, ...)
	assert(type(evname) == 'string', 'arg1 not a string')
	local evtbl = self._on[evname]
	if evtbl then
		for i=1, #evtbl do
			evtbl[i](...)
		end
	end
	local ev = self._once and self._once[evname]
	if ev then
		ev(...)
		if self._once then
			self._once[evname] = nil
		end
	end
end