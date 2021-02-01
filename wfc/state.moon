import empty, oneelem, same, inter, exclu from require 'wfc.set'

local Known, Possible, Unknown, _unknownstate
Known = (x) -> {Known, x}
Possible = (x) -> {Possible, x}
Unknown = -> _unknownstate
_unknownstate = {Unknown} -- only exists to avoid using *too much* ram, but they get turned into Possible nodes anyways and none of this is memoized anyways

sname = (x) ->
	switch x
		when Known then 'Known'
		when Possible then 'Possible'
		when Unknown then 'Unknown'
		else sname x[1]

sstring = (x) ->
	{state, val} = x
	switch state
		when Known then "Known #{val}"
		when Possible then "Possible #{table.concat [tostring e for e in pairs val], ', '}"
		when Unknown then "Unknown"

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

{
	:Known, :Possible, :Unknown
	:sname, :sstring
	:_fixed, :_set, :_subset, :_exclude
}
