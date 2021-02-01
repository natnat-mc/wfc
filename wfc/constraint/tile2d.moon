import cname, cstring, cvalid, capply from require 'wfc.constraint'
import setof from require 'wfc.util'
import hasinter from require 'wfc.set'
import Known, Possible, _subset, _exclude from require 'wfc.state'

Tile2D = (tile, border, diag, ...) -> {Tile2D, {tile, border, diag, setof ...}}

cname[Tile2D] = 'Tile2D'
cstring[Tile2D] = => "#{@[1]}; #{@[2]}; #{@[3]}; #{table.concat [tostring x for x in pairs @[4]], ', '}"

import match from string
import concat from table
getxy = (ref) ->
	x, y = match ref, '^(%-?%d+),(%-?%d+)$'
	(tonumber x), (tonumber y)
setxy = (x, y) ->
	"#{x},#{y}"

getneighbors = (x, y, diag) ->
	if diag
		{(setxy x-1, y), (setxy x+1, y), (setxy x, y-1), (setxy x, y+1), (setxy x-1, y-1), (setxy x-1, y+1), (setxy x+1, y-1), (setxy x+1, y+1)}, 8
	else
		{(setxy x-1, y), (setxy x+1, y), (setxy x, y-1), (setxy x, y+1)}, 4

cvalid[Tile2D] = (refs, domain) =>
	{tile, border, diag, allowed} = @
	for ref, v in pairs refs
		{rstate, rval} = v
		continue if rstate != Known or rval != tile
		x, y = getxy ref
		around, aroundn = getneighbors x, y, diag
		for i=1, aroundn
			sref = around[i]
			s = refs[sref]
			return false, "Tile2D border" if s == nil and not border
			continue if s == nil
			{sstate, sval} = s
			switch sstate
				when Known
					return false, "Tile2D Known" unless allowed[sval]
				when Possible
					return false, "Tile2D Possible" unless hasinter sval, allowed
	true

capply[Tile2D] = (refs, domain, try) =>
	{tile, border, diag, allowed} = @
	for ref, v in pairs refs
		{rstate, rval} = v
		x, y = getxy ref
		around, aroundn = getneighbors x, y, diag
		if rstate == Known and rval == tile
			for i=1, aroundn
				sref = around[i]
				s = refs[sref]
				print "cannot find #{sref}" if s == nil
				continue if s == nil
				try _subset refs, sref, allowed
		elseif rstate == Possible
			for i=1, aroundn
				sref = around[i]
				s = refs[sref]
				_exclude refs, ref, {[tile]: true} if s == nil and not border

Tile2D
