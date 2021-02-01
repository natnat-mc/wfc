import clone from require 'wfc.util'

-- inter x, y = x ∩ y
inter = (x, y) ->
	{k, y[k] for k in pairs x}

-- union x, y = x ∪ y
union = (x, y) ->
	a = clone x
	a[k] = true for k in pairs y
	a

-- exclu x, y = x \ y
exclu = (x, y) ->
	a = clone x
	a[k] = nil for k in pairs y
	a

-- compl x, y = y \ x
compl = (x, y) ->
	a = clone y
	a[k] = nil for k in pairs x
	a

-- empty x = card(x) == 0
empty = (x) ->
	not next x

-- oneelem x = card(x) == 1
oneelem = (x) ->
	(not empty x) and not next x, next x

-- nointer x, y = card(x ∩ y) == 0
nointer = (x, y) ->
	for k in pairs x
		return false if y[k]
	true

-- hasinter x, y = card(x ∩ y) != 0
hasinter = (x, y) ->
	for k in pairs x
		return true if y[k]
	false

-- same x, y = x == y
same = (x, y) ->
	for k in pairs x
		return false unless y[k]
	for k in pairs y
		return false unless x[k]
	true

{
	:clone
	:inter, :union, :exclu, :compl
	:empty, :oneelem
	:nointer, :hasinter
	:same
}
