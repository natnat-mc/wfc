-- clones a list, set or hash
clone = (x) ->
	{k, v for k, v in pairs x}

-- tests if x is a list
islist = (x) ->
	maxk = 0
	for k in pairs x
		return false if (type k) != 'number' or k < 1
		maxk = k if k > maxk
	#x == maxval

-- creates an array from an arglist
arrayof = (...) ->
	{...}

-- creates a set from an arglist
setof = (...) ->
	{(select i, ...), true for i=1, select '#', ...}

{
	:clone
	:islist
	:arrayof, :setof
}
