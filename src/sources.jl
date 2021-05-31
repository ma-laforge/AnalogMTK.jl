#Signal sources
#-------------------------------------------------------------------------------

#==SineSource
===============================================================================#
function SineSource(;name, V = 1.0, f = 1)
	𝜔 = 2π*f

	#Rename before re-using variables:
	_V = V; _f = f

	@parameters V f
	@named p = Pin()
	@named n = Pin()
	eqs = [
		0 ~ p.v - n.v - V*sin(𝜔*t)
		0 ~ p.i + n.i
	]
	ODESystem(eqs, t, [], [V], systems=[p, n], defaults=Dict(V=>_V, f=>_f), name=name)
end

#Last line
