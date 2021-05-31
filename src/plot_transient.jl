#AnalogMTK: Generate time-domain plots
#-------------------------------------------------------------------------------

#==plot_transient
===============================================================================#
function plot_transient(;ylabels::Vector{String}=["Voltage [V]"])
	nstrips = length(ylabels)
	plot = cons(:plot, linlin, title = "Transient", nstrips=nstrips, legend=true,
		labels=set(xaxis="Time"),
	)

	for (i, lbl) in enumerate(ylabels)
		set(plot, ystrip=set(i, axislabel=lbl))
	end
	return plot
end

function plot_transient!(plot, t, sig; id::String="", strip=1)
	wfrm = waveform(t, sig)
	push!(plot,
		cons(:wfrm, wfrm, line=set(style=:solid, width=2), label=id, strip=strip),
	)
	return plot
end

function plot_transient(args...; ylabels::Vector{String}=["Voltage [V]"], kwargs...)
	plot = plot_transient(;ylabels)
	plot_transient!(plot, args...; kwargs...)
end

#Last line
