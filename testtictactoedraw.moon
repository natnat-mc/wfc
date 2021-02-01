import Unknown from require 'wfc.state'
import Domain from require 'wfc.domain'
import NotAllSame, All from require 'wfc.constraint'
import solve from require 'wfc'

grid = [Unknown! for i=1, 3*3]
domain = Domain {'X', 'O'}

constraints = do
	c = {}
	for i in *({1, 2, 3})
		table.insert c, NotAllSame i, i+3, i+6
	for i in *({1, 4, 7})
		table.insert c, NotAllSame i, i+1, i+2
	table.insert c, NotAllSame 1, 5, 9
	table.insert c, NotAllSame 3, 5, 7
	{All, c}

math.randomseed os.time!
rst = solve grid, domain, constraints
for y=0, 2
	for x=1, 3
		io.write rst[y*3+x][2]
	io.write '\n'
