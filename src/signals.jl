#Signal sources
#-------------------------------------------------------------------------------

#==
===============================================================================#

struct Sine
	A::Float64
	f::Float64
end
Sine(;A=1, f=1) = Sine(A, f)

#Last