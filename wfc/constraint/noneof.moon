import cname, cstring, cvalid, capply from require 'wfc.constraint'
import setof from require 'wfc.util'
import hasinter, compl from require 'wfc.set'
import Known, Possible, _exclude from require 'wfc.state'

NoneOf = (x, ...) -> {NoneOf, {x, setof ...}}

cname[NoneOf] = 'NoneOf'
cstring[NoneOf] = => "#{@[1]}; #{table.concat [tostring x for x in *@[2]], ', '}"

cvalid[NoneOf] = (refs, domain) =>
	{ref, vals} = @
	{rstate, rval} = refs[ref]
	switch rstate
		when Known
			if vals[rval]
				false, "NoneOf Known"
			else
				true
		when Possible
			if hasinter rval, compl vals, domain.set
				true
			else
				false, "NoneOf Possible"

capply[NoneOf] = (refs, domain, try) =>
	{ref, vals} = @
	try _exclude refs, ref, vals

NoneOf

