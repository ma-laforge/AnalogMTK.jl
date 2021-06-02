module AnalogMTK


#==Base simulation engine
===============================================================================#
using ModelingToolkit
import ModelingToolkit.IfElse: ifelse
const MTK_PATH = abspath(joinpath(dirname(pathof(ModelingToolkit)), ".."))
@info("Using MTK_PATH: $MTK_PATH")


#==Plotting infrastructure
===============================================================================#
using CMDimData
using CMDimData.MDDatasets
using CMDimData.EasyPlot
using CMDimData.EasyPlot.Colors #Should be ok with whatever version it needs
import CMDimData.EasyPlot: BoundingBox #Use this one to avoid version conflicts with Graphics.
using InspectDR
CMDimData.@includepkg EasyPlotInspect


#Start using electrical components defined in MTK_PATH/examples/:
include(joinpath(MTK_PATH, "examples", "electrical_components.jl"))
include("base.jl")
include("signals.jl")
include("sources.jl")
include("diodes.jl")
include("display.jl")
include("plot_base.jl")
include("plot_transient.jl")

#Signal & device types
export Ideal, Shockley
export Sine

#Circuit element definitions:
export Resistor, Capacitor, Inductor
export Diode
export VSource
export Ground

#Plotting:
export plot_transient, plot_transient!

#Displaying plots:
export inlinedisp, saveimage, displaygui

#Inform user of the existance of `t`:
@info("NOTE: AnalogMTK also defines parameter `t`")

end # module
