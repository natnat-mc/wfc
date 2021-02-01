import Unknown, Known from require 'wfc.state'
import Domain from require 'wfc.domain'
import NotSame, All from require 'wfc.constraint'
import solve from require 'wfc'

sudoku = do
	x = nil
	b = {
		x, x, x, 1, x, 5, x, x, x
		1, 4, x, x, x, x, 6, 7, x
		x, 8, x, x, x, 2, 4, x, x
		x, 6, 3, x, 7, x, x, 1, x
		9, x, x, x, x, x, x, x, 3
		x, 1, x, x, 9, x, 5, 2, x
		x, x, 7, 2, x, x, x, 8, x
		x, 2, 6, x, x, x, x, 3, 5
		x, x, x, 4, x, 9, x, x, x
	}
	b = {
		x, 9, 2, x, x, 1, 7, 5, x
		5, x, x, 2, x, x, x, x, 8
		x, x, x, x, 3, x, 2, x, x
		x, 7, 5, x, x, 4, 9, 6, x
		2, x, x, x, 6, x, x, 7, 5
		x, 6, 9, 7, x, x, x, 3, x
		x, x, 8, x, 9, x, x, 2, x
		7, x, x, x, x, 3, x, 8, 9
		9, x, 3, 8, x, x, x, 4, x
	}
	[(if b[i] then Known b[i] else Unknown!) for i=1, 9*9]

domain = Domain {1, 2, 3, 4, 5, 6, 7, 8, 9}

constraints = do
	c = {}
	for i in *({1, 10, 19, 28, 37, 46, 55, 64, 73})
		-- horizontal lines
		table.insert c, NotSame i, i+1, i+2, i+3, i+4, i+5, i+6, i+7, i+8
	for i in *({1, 2, 3, 4, 5, 6, 7, 8, 9})
		-- vertical lines
		table.insert c, NotSame i, i+9, i+18, i+27, i+36, i+45, i+54, i+63, i+72
	for i in *({1, 4, 7, 28, 31, 34, 55, 58, 61})
		-- squares
		table.insert c, NotSame i, i+1, i+2, i+9, i+10, i+11, i+18, i+19, i+20
	{All, c}

solve sudoku, domain, constraints
