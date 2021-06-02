using ModelingToolkit, OrdinaryDiffEq
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
@named ZS = Resistor(R=100)
@named RL = Resistor(R=100)
@named CL = Capacitor(C=10e-9) #10e-6, 10e-9, 47e-9


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
#@named D1 = Diode(Ideal())
@named D1 = Diode(Shockley(), IS=1e-3)
#@named D1 = Resistor(R=1)
@named GND = Ground()

rc_eqs = [
	connect(Vsrc.p, ZS.p)
	connect(ZS.n, D1.p)
	connect(D1.n, RL.p, CL.p)
	connect(GND.g, Vsrc.n, RL.n, CL.n)
]

systems = [GND, Vsrc, ZS, D1, RL, CL]
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
      CL.p.i => 0.0,
      D1.v => 0.0,
     ]
prob = ODEProblem(sys, u0, (0, Float64(Tsim)))
sol = solve(prob, Trapezoid())
	#Trapezoid(), ImplicitEuler()
	#Rodas4(), RadauIIA5(), Tsit5()
@show length(sol.t)
println("\tdone.")


#==Plot results
===============================================================================#
println()
@info("Plotting results..."); flush(stdout); flush(stderr)
ylabels = ["Voltage [V]", "Current [A]"]
plot = plot_transient(sol.t, sol[Vsrc.p.v], id="Vsrc"; ylabels)
plot_transient!(plot, sol.t, sol[D1.v], id="D1.v")
plot_transient!(plot, sol.t, sol[CL.p.v], id="Vout")
plot_transient!(plot, sol.t, sol[RL.p.i], id="Iout", strip=2)
plot_transient!(plot, sol.t, sol[D1.i], id="D1.i", strip=2)
plot_transient!(plot, sol.t, sol[Vsrc.i], id="Vsrc.i", strip=2)
set(plot, ystrip1=set(min=-2, max=2))
displaygui(plot)
println("\tdone.")

:TEST_DONE

