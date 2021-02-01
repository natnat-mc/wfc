import cname, cstring, cvalid, capply from require 'wfc.constraint'
import arrayof from require 'wfc.util'
import union from require 'wfc.set'
import Known, Possible, _set from require 'wfc.state'

Any = (...) -> {Any, arrayof ...}

cname[Any] = 'Any'
cstring[Any] = => table.concat ["(#{cstring c})" for c in *@], ', '

cvalid[Any] = (refs, domain) =>
	for c in *@
		return true if cvalid refs, domain, c
	false, "Any"

capply[Any] = (refs, domain, try) =>
	tries, i = {}, 1
	touched = {}
	for c in *@
		touchedp = {}
		poss = setmetatable {},
			__index: refs
			__newindex: (k, v) =>
				rawset @, k, v
				touchedp[k] = true
		ok = pcall -> capply poss, domain, c
		if ok
			tries[i], i = poss, i + 1
			touched = union touched, touchedp
	error "Invalid state" if i==1
	for ref in pairs touched
		vals = {}
		for j=1, i-1
			{rstate, rval} = tries[j][ref]
			switch rstate
				when Known
					vals[rval] = true
				when Possible
					vals = union vals, rval
		try _set refs, ref, vals

Any
