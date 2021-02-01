import Unknown from require 'wfc.state'
import Domain from require 'wfc.domain'
import All, Tile2D from require 'wfc.constraint'
import solve from require 'wfc'

W = 80
H = 40

_G.print = ->

grid = do
	m = {}
	for x=1, W
		for y=1, H
			m["#{x},#{y}"] = Unknown!
	m

domain = Domain\frommap
	W: 40
	L: 45
	C: 10
	M: 5

constraints = do
	c = {}
	table.insert c, Tile2D 'W', false, false, 'W', 'C'
	table.insert c, Tile2D 'C', false, false, 'W', 'C', 'L'
	table.insert c, Tile2D 'L', true, false, 'C', 'L', 'M'
	table.insert c, Tile2D 'M', true, true, 'L', 'M'
	{All, c}

math.randomseed os.time!
rst = {k, x[2] for k, x in pairs solve grid, domain, constraints}

colors =
	W: 44
	C: 43
	L: 42
	M: 47

io.write "#{W}*#{H}\n"
for y=1, H
	for x=1, W
		io.write (string.char 27), '[', colors[rst["#{x},#{y}"]], 'm  '
	io.write (string.char 27), '[0m\n'
