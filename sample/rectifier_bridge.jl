using ModelingToolkit, OrdinaryDiffEq
#using IRKGaussLegendre #IRKGL16
using AnalogMTK
using AnalogMTK.EasyPlot #set, cons
import Printf: @sprintf
j=im


#==Circuit parameters
===============================================================================#
𝑓 = 60 #Hz
Tsim = 1 #sec

#@named Vsrc = VSource(1.0)
@named Vsrc = VSource(Sine(A=1, f=𝑓))
#@named ZS = Inductor(R=1e-3)
@named ZS = Resistor(R=50)
@named RL = Resistor(R=100)
@named CL = Capacitor(C=47e-9) #10e-6, 10e-9, 47e-9


#==Basic calculations & input validation
===============================================================================#
#=
𝜔 = 2π*𝑓
ZC = 1/(j*𝜔*C)

println()
@info("Simulation parameters:")
@show V, 𝑓, 𝜔
@show R, C, abs(ZC)

@show 𝜏 = R*C
=#

#==Circuit definition
===============================================================================#
if true
@named D1 = Diode(Shockley(), IS=1e-3)
@named D2 = Diode(Shockley(), IS=1e-3)
@named D3 = Diode(Shockley(), IS=1e-3)
@named D4 = Diode(Shockley(), IS=1e-3)

elseif true #Debug: half on
@named D1 = Diode(Shockley(), IS=1e-6)
#@named D1 = Resistor(R=0)
@named D2 = Resistor(R=1e10)
@named D3 = Diode(Shockley(), IS=1e-6)
#@named D3 = Resistor(R=0)
@named D4 = Resistor(R=1e10)
end

@named GND = Ground()
systems = [GND, Vsrc, ZS, D1, D2, D3, D4, RL, CL]

rc_eqs = [
	connect(Vsrc.p, ZS.p)
	connect(ZS.n, D1.p, D4.n)
	connect(D1.n, D2.n, RL.n, CL.n)
	connect(D4.p, D3.p, RL.p, CL.p)
	connect(GND.g, Vsrc.n, D2.p, D3.n)
]

@named rc_model = ODESystem(rc_eqs, AnalogMTK.t; systems)

println()
@info("Initial ODESystem (model definition):"); flush(stdout); flush(stderr)
display(rc_model)


println()
@info("Computing simplified model (ODESystem)..."); flush(stdout); flush(stderr)
#sys = rc_model
sys = structural_simplify(rc_model)
display(sys)
println("\tdone.")


#==Circuit simulation
===============================================================================#
println()
@info("Running simulation..."); flush(stdout); flush(stderr)
u0 = [
      ZS.v => 0.0,
      CL.v => 0.0,
#      CL.p.i => 0.0,
      D1.v => 0.0,
      D2.v => 0.0,
      D3.v => 0.0,
      D4.v => 0.0,
     ]
u0 = zeros(4)
#u0 = zeros(6)

prob = ODEProblem(sys, u0, (0, Float64(Tsim)))#, jac=true)
#, abstol=1e-4, reltol=1e-5)
sol = solve(prob, Trapezoid(), abstol=1e-4, reltol=1e-5)
	#Trapezoid(), ImplicitEuler()
	#Rodas4(), RadauIIA5(), Tsit5()
	#IRKGL16()
@show length(sol.t)
println("\tdone.")


#==Plot results
===============================================================================#
println()
@info("Plotting results..."); flush(stdout); flush(stderr)
ylabels = ["Voltage [V]", "Current [A]"]
plot = plot_transient(sol.t, sol[Vsrc.v], id="Vsrc"; ylabels)
plot_transient!(plot, sol.t, sol[ZS.n.v], id="ZS.n.v")
plot_transient!(plot, sol.t, sol[D1.v], id="D1.v")
plot_transient!(plot, sol.t, sol[RL.p.v], id="Vout+")
plot_transient!(plot, sol.t, sol[RL.n.v], id="Vout-")
plot_transient!(plot, sol.t, sol[RL.p.i], id="Iout", strip=2)
#plot_transient!(plot, sol.t, sol[D1.i], id="D1.i", strip=2)
plot_transient!(plot, sol.t, sol[Vsrc.i], id="Vsrc.i", strip=2)
set(plot, ystrip1=set(min=-2, max=2))
displaygui(plot)
println("\tdone.")

:TEST_DONE

