#AnalogMTK: Diodes
#-------------------------------------------------------------------------------

const kb = 1.380649e-23 #[J/K] Boltzman constant
const qe = -1.602176634e-19 #[C] Electron charge

#Defaults
const DFLT_T = 300 #[K] temperature
const DFLT_VT = kb*DFLT_T/abs(qe) #Diode thermal voltage

struct Shockley
end

#==
===============================================================================#

#Has convergeance issues?
function Diode(::Ideal; name)
@warn("Has convergeance issues???")
	gmin = 1e-12

	@named(p = Pin()); @named(n = Pin())
	@variables v(t) i(t)
	eqs = [
		v ~ p.v - n.v
#		0 ~ p.i + n.i - gmin*(p.v-n.v) #in = -out (w/gmin)
#		i ~ p.i - gmin*p.v #Positive current flows into p terminal
		0 ~ p.i + n.i #in = -out
		i ~ p.i - gmin*v #Positive current flows into p terminal
		0 ~ ifelse(v<0, i, v)
	]
	ODESystem(eqs, t, [v, i], [], systems=[p, n], defaults=Dict(), name=name)
end

function Diode(::Shockley; name::Symbol, IS=1e-15, VT=DFLT_VT, η=1.0)
	ηVT = η*VT

	#Rename before re-using variables:
	_IS = IS; _VT=VT; _η=η
	@parameters IS, VT, η
	defaults = Dict(IS=>_IS, VT=>_VT, η=>_η)

	#Rename before re-using pin name:
#	_n=n
	@named(p = Pin()); @named(n = Pin())
	@variables v(t) i(t)
	eqs = [
		v ~ p.v - n.v
		0 ~ p.i + n.i #in = -out
		i ~ p.i #Positive current flows into p terminal
		i ~ IS*(exp(v/ηVT)-1)
	]

	ODESystem(eqs, t, [v, i], keys(defaults), systems=[p, n]; defaults, name)
end


#Last line
