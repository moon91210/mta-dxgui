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
	local ev = {}
	ev.callback = callback
	local evtbl = self._on[evname]
	if not evtbl then
		evtbl = {}
		self._on[evname] = evtbl
	end
	table.insert(evtbl, ev)
	return self
end

function Emitter:once(evname, callback)
	assert(type(evname) == 'string', 'arg1 not a string')
	assert(type(callback) == 'function', 'arg2 not a function')
	self._once[evname] = callback
	return self
end

function Emitter:emit(evname, ...)
	assert(type(evname) == 'string', 'arg1 not a string')
	local evtbl = self._on[evname]
	if evtbl then
		for i=1, #evtbl do
			evtbl[i].callback(...)
		end
	end
	local ev = self._once[evname]
	if ev then
		ev(...)
		self._once[evname] = nil
	end
end

function Emitter:removeOn(evname, callback)
	local evtbl = self._on[evname]
	if evtbl then
		for i=1, #evtbl do
			if evtbl[i].callback == callback then
				table.remove(evtbl, i)
				break
			end
		end
	end
end