local All, Any
local Same, NotSame
local OneOf

arrayof = (...) -> {...}
setof = (...) -> {(select i, ...), true for i=1, select '#', ...}

All = (...) -> {All, arrayof ...}
Any = (...) -> {Any, arrayof ...}

Same = (...) -> {Same, arrayof ...}
NotSame = (...) -> {NotSame, arrayof ...}

OneOf = (x, ...) -> {OneOf, {x, setof ...}}
NoneOf = (x, ...) -> {NoneOf, {x, setof ...}}

cname = (x) ->
	switch x
		when All then 'All'
		when Any then 'Any'
		when Same then 'Same'
		when NotSame then 'NotSame'
		when OneOf then 'OneOf'
		when NoneOf then 'NoneOf'
		else cname x[1]

cstring = (x) ->
	{cname, cparm} = x
	switch cname
		when All then "All #{table.concat ["(#{cstring c})" for c in *cparm], ', '}"
		when Any then "Any #{table.concat ["(#{cstring c})" for c in *cparm], ', '}"
		when Same then "Same #{table.concat [tostring x for x in *cparm], ', '}"
		when NotSame then "NotSame #{table.concat [tostring x for x in *cparm], ', '}"
		when OneOf then "OneOf #{cparm[1]}; #{table.concat [tostring x for x in *cparm[2]], ', '}"
		when NoneOf then "NoneOf #{cparm[1]}; #{table.concat [tostring x for x in *cparm[2]], ', '}"

{
	:All, :Any
	:Same, :NotSame
	:OneOf, :NoneOf
	:cname, :cstring
}
