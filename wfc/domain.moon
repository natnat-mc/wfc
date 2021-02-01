import random from math

class Domain
	new: (@values, @weights=[1 for v in *values]) =>
		@ascendingweights = {}
		currweight = 0
		for i, w in ipairs weights
			currweight += w
			@ascendingweights[i] = currweight
		@maxweight = currweight
		@nvalues = #values
		@rev = {v, i for i, v in ipairs values}
		@set = {v, true for v in *values}
		if @nvalues == @maxweight
			@pick = @pickuniform
			@pickamong = @pickamonguniform

	@frommap: (values) =>
		ks, vs = {}, {}
		i = 1
		for k, v in pairs values
			ks[i], vs[i], i = k, v, i + 1
		@ ks, vs

	pick: =>
		--TODO bissect instead of doing a linear search for big lists
		n = random @maxweight
		for i=1, @nvalues
			return @values[i] if n <= @ascendingweights[i]
		error "Unreachable, #{n} out of #{@maxweight}"

	pickamong: (pool) =>
		--TODO memoize this?
		return @pick! if pool == @values
		ascw, i = {}, 1
		cw = 0
		for v in *pool
			cw += @weights[@rev[v]]
			ascw[i], i = cw, i + 1
		x = random cw
		for y=1, i-1
			return pool[y] if x <= ascw[y]
		error "Unreachable, #{x} out of #{cw}"

	pickuniform: =>
		@values[random @nvalues]

	pickamonguniform: (pool) =>
		pool[random #pool]

{ :Domain }
