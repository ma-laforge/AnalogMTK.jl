#Signal sources
#-------------------------------------------------------------------------------

#==
===============================================================================#


#==
===============================================================================#
function VSource(sig::Sine; name)
	𝜔 = 2π*sig.f

	@parameters A f
	defaults = Dict(A=>sig.A, f=>sig.f)

	@named(p = Pin()); @named(n = Pin())
	@variables v(t) i(t)
	eqs = [
		v ~ p.v - n.v
		0 ~ p.i + n.i #in = -out
		i ~ -p.i #Positive current flows *out* of p terminal
		v ~ sig.A*sin(𝜔*t)
	]
	ODESystem(eqs, t, [v, i], keys(defaults), systems=[p, n]; defaults, name)
end

function VSource(V::Real; name)
	#Rename before re-using variables:
	_V = V
	@parameters V
	defaults = Dict(V=>_V)

	@named(p = Pin()); @named(n = Pin())
	@variables v(t) i(t)
	eqs = [
		v ~ p.v - n.v
		0 ~ p.i + n.i #in = -out
		i ~ -p.i #Positive current flows *out* of p terminal
		v ~ V
	]
	ODESystem(eqs, t, [v, i], keys(defaults), systems=[p, n]; defaults, name)
end


Ideal

#Last line
