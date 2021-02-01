import cname, cstring, cvalid, capply from require 'wfc.constraint'
import setof from require 'wfc.util'
import hasinter from require 'wfc.set'
import Known, Possible, _subset from require 'wfc.state'

OneOf = (x, ...) -> {OneOf, {x, setof ...}}

cname[OneOf] = 'OneOf'
cstring[OneOf] = => "#{@[1]}; #{table.concat [tostring x for x in *@[2]], ', '}"

cvalid[OneOf] = (refs, domain) =>
	{ref, vals} = @
	{rstate, rval} = refs[ref]
	switch rstate
		when Known
			if vals[rval]
				true
			else
				false, "OneOf Known"
		when Possible
			if hasinter vals, rval
				true
			else
				false, "OneOf Possible"

capply[OneOf] = (refs, domain, try) =>
	{ref, vals} = @
	try _subset refs, ref, vals

OneOf
