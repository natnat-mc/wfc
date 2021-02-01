import All, Any, Same, NotSame, OneOf, NoneOf, cname from require 'wfc.constraint'
import Known, Possible, Unknown, sstring from require 'wfc.state'

-- clones a dict, set or list
clone = (x) ->
	{k, v for k, v in pairs x}

-- random functions
islist = (x) ->
	maxk = 0
	for k in pairs x
		return false if (type k) != 'number' or k < 1
		maxk = k if k > maxk
	#x == maxval

-- operations on sets
--TODO move to a "wfc.set" module
inter = (x, y) ->
	{k, y[k] for k in pairs x}
union = (x, y) ->
	a = clone x
	a[k] = true for k in pairs y
	a
exclu = (x, y) ->
	a = clone x
	a[k] = nil for k in pairs y
	a
compl = (x, y) ->
	a = clone y
	a[k] = nil for k in pairs x
	a
empty = (x) ->
	not next x
oneelem = (x) ->
	(not empty x) and not next x, next x
nointer = (x, y) ->
	for k in pairs x
		return false if y[k]
	true
hasinter = (x, y) ->
	for k in pairs x
		return true if y[k]
	false
same = (x, y) ->
	for k in pairs x
		return false unless y[k]
	for k in pairs y
		return false unless x[k]
	true

-- pretty-prints a system
pprint = (refs) ->
	print "pprint"
	a, b, c = if islist refs then ipairs refs else pairs refs
	for k, v in a, b, c
		print "\t#{k}:\t#{sstring v}"

-- checks if a system is fully solved
issolved = (refs) ->
	for ref, v in pairs refs
		{rstate} = v
		return false unless rstate == Known
	true

-- checks that the constraints are still all valid
isvalid = (refs, domain, constraints) ->
	{ctype, cparm} = constraints
	switch ctype
		when All
			for c in *cparm
				return false unless isvalid refs, domain, c
			true
		when Any
			for c in *cparm
				return true if isvalid refs, domain, c
			false
		when Same
			known, v = false, nil
			for ref in *cparm
				{rstate, rval} = refs[ref]
				switch rstate
					when Known
						return false if known and v != rval
						known, v = true, rval
					when Possible
						return false if known and not rval[v]
			true
		when NotSame
			seen = {}
			for ref in *cparm
				{rstate, rval} = refs[ref]
				switch rstate
					when Known
						return false if seen[rval]
						seen[rval] = true
			for ref in *cparm
				{rstate, rval} = refs[ref]
				switch rstate
					when Possible
						some = false
						for v in pairs rval
							some = true unless seen[v]
						return false unless some
			true
		when OneOf
			{ref, vals} = cparm
			{rstate, rval} = refs[ref]
			switch rstate
				when Known
					vals[rval]
				when Possible
					hasinter vals, rval
				when Unknown
					true
		when NoneOf
			{ref, vals} = cparm
			{rstate, rval} = refs[ref]
			switch rstate
				when Known
					not vals[rval]
				when Possible
					hasinter vals, compl rval, domain.set
				when Unknown
					true
		else
			error "Invalid constraint"

-- sets a subset of values to the set of possibilities of a ref
_subset = (refs, ref, set) ->
	{rstate, rval} = refs[ref]
	switch rstate
		when Known
			error "Invalid state" unless set[rval]
			true -- did nothing
		when Possible
			t = inter rval, set
			error "Invalid state" if empty t
			if oneelem t
				refs[ref] = Known next t
				false -- did something
			else
				refs[ref] = Possible t
				same t, rval -- might have stalled

-- removes a set of values from the set of possibilities of a ref
_exclude = (refs, ref, set) ->
	{rstate, rval} = refs[ref]
	switch rstate
		when Known
			error "Invalid state" if set[rval]
			true -- did nothing
		when Possible
			t = exclu rval, set
			error "Invalid state" if empty t
			if oneelem t
				refs[ref] = Known next t
				false -- did something
			else
				refs[ref] = Possible t
				same t, rval -- might have stalled

-- sets a ref to a fixed value
_fixed = (refs, ref, val) ->
	{rstate, rval} = refs[ref]
	switch rstate
		when Known
			error "Invalid state" unless rval == val
			true -- did nothing
		when Possible
			error "Invalid state" unless rval[val]
			refs[ref] = Known val
			false -- always did something

-- sets a ref to a fixed set of possibilities
_set = (refs, ref, set) ->
	return _fixed refs, ref, next set if oneelem set
	{rstate, rval} = refs[ref]
	switch rstate
		when Known
			error "Invalid state"
		when Possible
			refs[ref] = Possible set
			same set, rval -- might have stalled

-- apply constraints to the system to reduce the possibilities as much as possible
-- returns true if it stalled
doconstraints = (refs, domain, constraints) ->
	{ctype, cparm} = constraints
	stalled = true
	try = (x) ->
		stalled and= x
	switch ctype
		when All
			for c in *cparm
				try doconstraints refs, domain, c
		when Any
			error "Unimplemented"
		when Same
			known, v = 'not', clone domain.set
			for ref in *cparm
				{rstate, rval} = refs[ref]
				switch rstate
					when Known
						known, v = 'val', rval
						break
					when Possible
						known, v = 'set', inter v, rval
			if known == 'set' and oneelem v
				known, v = 'val', next v
			switch known
				when 'val'
					try _fixed refs, ref, v for ref in *cparm
				when 'set'
					try _set refs, ref, v for ref in *cparm
		when NotSame
			seen = {}
			for ref in *cparm
				{rstate, rval} = refs[ref]
				switch rstate
					when Known
						seen[rval] = true
			if not empty seen
				for ref in *cparm
					{rstate, rval} = refs[ref]
					switch rstate
						when Possible
							try _exclude refs, ref, seen
		when OneOf
			{ref, vals} = cparm
			try _subset refs, ref, vals
		when NoneOf
			{ref, vals} = cparm
			try _exclude refs, ref, vals
		else
			error "Invalid constraint"
	stalled

-- replace Unknown nodes with Possible nodes with the whole domain
dounknowns = (refs, domain) ->
	for ref, v in pairs refs
		{rstate} = v
		refs[ref] = Possible domain.set if rstate == Unknown

-- replace Possible nodes with Known constants if there is only one possible value
doconstants = (refs) ->
	for ref, v in pairs refs
		{rstate, rval} = v
		refs[ref] = Known next rval if rstate == Possible and oneelem rval

-- determine the priority of a given ref, higher number is higher priority
priority = (refs, ref, domain, constraints) ->
	-- for now, priority only considers the number of forks, negative so that less is better
	-#refs[ref][2]

-- solve a problem defined by refs, a domain and a constraint (which is probably an All constraint)
solve = (refs, domain, constraints) ->
	-- clone the refs
	print "clone"
	refs = clone refs
	-- turn Unknown into Possible with the entire domain
	print "dounknowns"
	dounknowns refs, domain, constraints

	-- loop until we stall
	stalled = false
	while not stalled
		-- check if all constraints are still possible
		print "isvalid"
		error "Invalid state" unless isvalid refs, domain, constraints
		-- check if the state is already solved
		print "issolved"
		return refs if issolved refs
		-- enforce constraints
		print "doconstraints"
		stalled = doconstraints refs, domain, constraints
		unless stalled
			-- turn Possible into Known if we can
			print "doconstants"
			doconstants refs
		pprint refs
	print "stalled"
	-- so by that point we have stalled

	-- check if the state is already solved
	print "issolved"
	return refs if issolved refs

	-- if we're here, we *need* to fork
	-- first, find the cell with the highest priority
	-- for a simple solver, the priority function can just be a flat value or the number of forks
	-- for a generator, the priority should consider proximity, number of forks and constraints
	print "getprio"
	ref = do
		refks = [k for k, v in pairs refs when v[1] == Possible]
		maxprio, candidate = -math.huge, nil
		for ref in *refks
			prio = priority refs, ref, domain, constraints
			maxprio, candidate = prio, ref if prio > maxprio
		candidate
	error "Invalid state" unless ref

	-- try every possible value for the ref we selected
	print "fork"
	for v in pairs refs[ref][2]
		-- clone the current state of the refs
		newrefs = clone refs
		-- make a guess
		newrefs[ref] = Known v
		-- and call the solver recursively
		success, result = pcall solve, newrefs, domain, constraints
		-- give our result if the recursive call succeeded
		return result if success
	error "Invalid state"


{ :solve }
