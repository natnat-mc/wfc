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

{
	:Known, :Possible, :Unknown
	:sname, :sstring
}
