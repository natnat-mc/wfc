import cname, cstring, cvalid, capply from require 'wfc.constraint'
import arrayof from require 'wfc.util'
import clone, inter, oneelem from require 'wfc.set'
import Known, Possible, _fixed, _set from require 'wfc.state'

Same = (...) -> {Same, arrayof ...}

cname[Same] = 'Same'
cstring[Same] = => table.concat [tostring x for x in *@], ', '

cvalid[Same] = (refs, domain) =>
	known, v = false, nil
	for ref in *@
		{rstate, rval} = refs[ref]
		switch rstate
			when Known
				return false, "Same Known" if known and v != rval
				known, v = true, rval
	for ref in *@
		{rstate, rval} = refs[ref]
		switch rstate
			when Possible
				return false, "Same Possible" if known and not rval[v]
	true

capply[Same] = (refs, domain, try) =>
	known, v = 'not', clone domain.set
	for ref in *@
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
			try _fixed refs, ref, v for ref in *@
		when 'set'
			try _set refs, ref, v for ref in *@

Same
