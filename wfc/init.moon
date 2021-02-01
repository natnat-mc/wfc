import cvalid, capply from require 'wfc.constraint'
import Known, Possible, Unknown, sstring from require 'wfc.state'
import empty, oneelem from require 'wfc.set'
import clone, islist from require 'wfc.util'

-- pretty-prints a system
pprint = (refs) ->
	print "pprint"
	a, b, c = if islist refs then ipairs refs else pairs refs
	for k, v in a, b, c
		print "\t#{k}:\t#{sstring v}"

-- checks if a system is fully solved
issolved = (refs) ->
	for ref, v in pairs refs
		{rstate} = v
		return false unless rstate == Known
	true

-- replace Unknown nodes with Possible nodes with the whole domain
dounknowns = (refs, domain) ->
	for ref, v in pairs refs
		{rstate} = v
		refs[ref] = Possible domain.set if rstate == Unknown

-- replace Possible nodes with Known constants if there is only one possible value
doconstants = (refs) ->
	for ref, v in pairs refs
		{rstate, rval} = v
		refs[ref] = Known next rval if rstate == Possible and oneelem rval

-- determine the priority of a given ref, higher number is higher priority
priority = (refs, ref, domain, constraints) ->
	-- for now, priority only considers the number of forks, negative so that less is better
	-#refs[ref][2]

-- get the cell with the highest priority
getprio = (refs, domain, constraints) ->
	refks = [k for k, v in pairs refs when v[1] == Possible]
	maxprio, candidate = -math.huge, nil
	for ref in *refks
		prio = priority refs, ref, domain, constraints
		maxprio, candidate = prio, ref if prio > maxprio
	candidate or error "Invalid state"

-- get possible values in a random (weighted) order for a given cell
getvals = (refs, ref, domain) ->
	possible = clone refs[ref][2]
	->
		return nil if empty possible
		try = domain\pickamong [x for x in pairs possible]
		possible[try] = nil
		try

-- actually solve a problem
solveimp = (refs, domain, constraints) ->
	-- loop until we stall
	stalled = false
	while not stalled
		-- check if all constraints are still possible
		print "cvalid"
		do
			valid, msg = cvalid refs, domain, constraints
			error "Invalid state: #{msg}" unless valid
		-- check if the state is already solved
		print "issolved"
		return refs if issolved refs
		-- enforce constraints
		print "capply"
		stalled = capply refs, domain, constraints
		unless stalled
			-- turn Possible into Known if we can
			print "doconstants"
			doconstants refs
		pprint refs
	print "stalled"
	-- so by that point we have stalled

	-- check if the state is already solved
	print "issolved"
	return refs if issolved refs

	-- if we're here, we *need* to fork
	-- first, find the cell with the highest priority
	print "getprio"
	ref = getprio refs, domain, constraints

	-- try every possible value for the ref we selected
	print "fork"
	for v in getvals refs, ref, domain
		-- clone the current state of the refs
		newrefs = clone refs
		-- make a guess
		print "guess #{ref} = #{v}"
		newrefs[ref] = Known v
		-- and call the solver recursively
		success, result = pcall -> solveimp newrefs, domain, constraints
		-- give our result if the recursive call succeeded
		return result if success
		print "wasnt valid: #{result}"
	error "No valid state"

-- solve a problem defined by refs, a domain and a constraint (which is probably an All constraint)
solve = (refs, domain, constraints) ->
	-- clone the refs
	print "clone"
	refs = clone refs
	-- turn Unknown into Possible with the entire domain
	print "dounknowns"
	dounknowns refs, domain, constraints
	-- and actually solve the thing
	solveimp refs, domain, constraints

{ :solve }
