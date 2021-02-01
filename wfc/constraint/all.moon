import cname, cstring, cvalid, capply from require 'wfc.constraint'
import arrayof from require 'wfc.util'

All = (...) -> {All, arrayof ...}

cname[All] = 'All'
cstring[All] = => table.concat ["(#{cstring c})" for c in *@], ', '

cvalid[All] = (refs, domain) =>
	for c in *@
		x, msg = cvalid refs, domain, c
		return false, msg unless x
	true

capply[All] = (refs, domain, try) =>
	for c in *@
		try capply refs, domain, c

All
