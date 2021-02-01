import cname, cstring, cvalid, capply from require 'wfc.constraint'
import arrayof from require 'wfc.util'
import empty from require 'wfc.set'
import Known, Possible, _exclude from require 'wfc.state'

NotSame = (...) -> {NotSame, arrayof ...}

cname[NotSame] = 'NotSame'
cstring[NotSame] = => table.concat [tostring x for x in *@], ', '

cvalid[NotSame] = (refs, domain) =>
	seen = {}
	for ref in *@
		{rstate, rval} = refs[ref]
		switch rstate
			when Known
				return false, "NotSame Known" if seen[rval]
				seen[rval] = true
	for ref in *@
		{rstate, rval} = refs[ref]
		switch rstate
			when Possible
				some = false
				for v in pairs rval
					some = true unless seen[v]
				return false, "NotSame Possible" unless some
	true

capply[NotSame] = (refs, domain, try) =>
	seen = {}
	for ref in *@
		{rstate, rval} = refs[ref]
		switch rstate
			when Known
				seen[rval] = true
	if not empty seen
		for ref in *@
			{rstate, rval} = refs[ref]
			switch rstate
				when Possible
					try _exclude refs, ref, seen

NotSame
