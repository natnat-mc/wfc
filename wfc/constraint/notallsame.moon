import cname, cstring, cvalid, capply from require 'wfc.constraint'
import arrayof from require 'wfc.util'
import Known, Possible, _exclude from require 'wfc.state'

NotAllSame = (...) -> {NotAllSame, arrayof ...}

cname[NotAllSame] = 'NotAllSame'
cstring[NotAllSame] = => table.concat [tostring x for x in *@], ', '

cvalid[NotAllSame] = (refs, domain) =>
	streak, v = 0, nil
	for ref in *@
		{rstate, rval} = refs[ref]
		switch rstate
			when Known
				if v == rval
					streak += 1
				else
					streak, v = 1, rval
	numref = #@
	numref != streak, "NotAllSame all"

capply[NotAllSame] = (refs, domain, try) =>
	streak, v = 0, nil
	for ref in *@
		{rstate, rval} = refs[ref]
		switch rstate
			when Known
				if v == rval
					streak += 1
				else
					streak, v = 1, rval
	numref = #@
	error "Invalid state" if numref == streak
	if numref == streak + 1
		for ref in *@
			{rstate, rval} = refs[ref]
			switch rstate
				when Possible
					try _exclude refs, ref, {[v]: true}

NotAllSame
