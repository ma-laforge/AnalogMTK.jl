#AnalogMTK: Base plot generation tools
#-------------------------------------------------------------------------------

#==Useful constants
===============================================================================#
const linlin = cons(:a, xyaxes=set(xscale=:lin, yscale=:lin))
const linlog = cons(:a, xyaxes=set(xscale=:lin, yscale=:log))
const loglin = cons(:a, xyaxes=set(xscale=:log, yscale=:lin))
const loglog = cons(:a, xyaxes=set(xscale=:log, yscale=:log))

const dfltline = cons(:a, line=set(style=:solid, color=:blue, width=2))


#==Validation
===============================================================================#
#Validate x, y pair simple vectors
function validatexy_vec(x, y)
	sz = size(x); sz_y = size(y)
	if sz != sz_y
		throw("x & y sizes do not match")
	elseif length(sz) > 1
		throw("Dimension of data too large (Simple vector expected).")
	end
	return
end

#Validate x, y pair for 1 parameter sweep (2D array)
function validatexy_1param(x, y)
	sz = size(x); sz_y = size(y)
	if sz != sz_y
		throw("x & y sizes do not match")
	elseif length(sz) > 2
		throw("Dimension of data too large (2D arrays expected).")
	end
	return
end


#==Waveform builders
===============================================================================#
function _wfrm__(x::Vector, y::Vector, sweepid::String)
	validatexy_vec(x, y)
	return DataF1(x,y)
end
_wfrm__(x::AbstractVector, y::Vector, sweepid::String) = _wfrm__(collect(x), y, sweepid)
function _wfrm__(x::Array{Float64,2}, y::Array{Float64,2}, sweepid::String)
	validatexy_1param(x, y)
	N = size(x, 1)
	wfrm = fill(DataRS{DataF1}, PSweep(sweepid, collect(1:N))) do i
		return DataF1(x[i,:], y[i,:]) #Returns from implicit "do" function
	end
	return wfrm
end

"""`waveform(x, y; sweepid="i")`

Create a waveform object with a given string to identify the sweep.
"""
waveform(x, y; sweepid::String="i") = _wfrm__(x, y, sweepid)

#Last line
