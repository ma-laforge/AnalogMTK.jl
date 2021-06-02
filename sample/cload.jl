using ModelingToolkit, OrdinaryDiffEq
using AnalogMTK
using AnalogMTK.EasyPlot #set, cons
import Printf: @sprintf
j=im


#==Circuit parameters
===============================================================================#
R = 1000
C = 10e-6 #10e-6, 10e-9
V = 1.0
𝑓 = 60 #Hz


#==Basic calculations
===============================================================================#
𝜔 = 2π*𝑓
ZC = 1/(j*𝜔*C)

println()
@info("Simulation parameters:")
@show V, 𝑓, 𝜔
@show R, C, abs(ZC)

𝜏 = R*C
@show 𝜏


#==Circuit definition
===============================================================================#
@named resistor = Resistor(R=R)
@named capacitor = Capacitor(C=C)
#@named source = VSource(V)
@named source = VSource(Sine(A=V, f=𝑓))
@named ground = Ground()

rc_eqs = [
          connect(source.p, resistor.p)
          connect(resistor.n, capacitor.p)
          connect(capacitor.n, source.n, ground.g)
         ]

@named rc_model = ODESystem(rc_eqs, AnalogMTK.t, systems=[resistor, capacitor, source, ground])

println()
@info("Initial ODESystem (model definition):"); flush(stdout); flush(stderr)
display(rc_model)


println()
@info("Computing simplified model (ODESystem)..."); flush(stdout); flush(stderr)
sys = structural_simplify(rc_model)
display(sys)
println("\tdone.")


#==Circuit simulation
===============================================================================#
println()
@info("Running simulation..."); flush(stdout); flush(stderr)
u0 = [
      capacitor.v => 0.0
      capacitor.p.i => 0.0
      resistor.v => 0.0
     ]
prob = ODEProblem(sys, u0, (0, 10.0))
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
plot = plot_transient(sol.t, sol[source.p.v], id="Vsrc"; ylabels)
plot_transient!(plot, sol.t, sol[capacitor.p.v], id="Vout")
plot_transient!(plot, sol.t, sol[capacitor.p.i], id="Iout", strip=2)
displaygui(plot)
println("\tdone.")

:TEST_DONE
