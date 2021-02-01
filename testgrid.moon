import Unknown from require 'wfc.state'
import Domain from require 'wfc.domain'
import NotSame, Same, OneOf, NoneOf, All, Any from require 'wfc.constraint'
import solve from require 'wfc'

grid = [Unknown! for i=1, 4*4]
domain = Domain {1, 2, 3, 4}

constraints = do
	c = {}
	for i in *({1, 5, 9, 13})
		-- horizontal lines
		table.insert c, Same i, i+1, i+2, i+3
	for i in *({1, 2, 3, 4})
		-- vertical lines
		table.insert c, NotSame i, i+4, i+8, i+12
	table.insert c, OneOf 1, 1, 2, 3
	table.insert c, OneOf 2, 1, 3, 4
	table.insert c, NoneOf 3, 3, 4
	table.insert c, NoneOf 5, 1, 3
	table.insert c, OneOf 6, 2, 4
	table.insert c, NoneOf 16, 1, 3
	table.insert c, Any (OneOf 4, 1), (OneOf 4, 3)
	{All, c}

solve grid, domain, constraints
