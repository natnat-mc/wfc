local constraints

cname = setmetatable {},
	__call: (x) =>
		@[x] or @[x[1]] or "[unknown constraint]"

cstring = setmetatable {},
	__call: (x) ->
		f = @[x] or => "[unknown params]"
		"#{cname x[1]} #{f x[2]}"

cvalid = setmetatable {},
	__call: (refs, domain, c) =>
		{ctype, cparm} = c
		cv = @[ctype] or error "Invalid constraint #{cname ctype}"
		ok, msg = cv cparm, refs, domain
		if ok
			true
		else
			false, "#{cname ctype}: #{msg}"

capply = setmetatable {},
	__call: (refs, domain, c) =>
		{ctype, cparm} = c
		cf = @[ctype] or error "Invalid constraint #{cname ctype}"
		stalled = true
		try = (x) -> stalled and= x
		cf cparm, refs, domain, try
		stalled

register = (constraint) ->
	switch type constraint
		when 'function'
			name = cname[constraint] or error "No constraint name"
			error "No constraint validity" unless cvalid[constraint]
			error "No constraint applicator" unless capply[constraint]
			rawset constraints, name, constraint
			constraint
		when 'table'
			c = constraint[1]
			cname[c] = constraint.name or error "No constraint name"
			cstring[c] = constraint.string
			cvalid[c] = constraint.valid or error "No constraint validity"
			capply[c] = constraint.apply or error "No constraint applicator"
			rawset constraints, cname[c], c
			c
		when 'string'
			register require constraint

constraints = {
	:cname, :cstring
	:cvalid, :capply
	:register
}
setmetatable constraints,
	__index: (k) =>
		pcall -> register require "wfc.constraint.#{k\lower!}"
		rawget @, k
