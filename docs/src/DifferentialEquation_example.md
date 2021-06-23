```@meta
EditURL = "<unknown>/../examples/DifferentialEquation_example.jl"
```

```@example DifferentialEquation_example
using AmbientForcing
using OrdinaryDiffEq, Distributions
```

adopting the Robertson Example from the DifferentialEquation docs
https://diffeq.sciml.ai/stable/tutorials/advanced_ode_example/#Handling-Mass-Matrices

```@example DifferentialEquation_example
function rober(du,u,p,t)
    y₁,y₂,y₃ = u
    du[1] = -0.04 * y₁ + 1e4 * y₂ * y₃
    du[2] =  0.04 * y₁ - 1e4 * y₂ * y₃ - 3e7 * y₂^2
    du[3] =  y₁ + y₂ + y₃ - 1
    nothing
  end
```

creating the mass_matrix, the last equation is our constraint

```@example DifferentialEquation_example
  M = [1. 0  0
       0  1. 0
       0  0  0];
nothing #hide
```

Setting up the DAE as an ODE in mass matrix form

```@example DifferentialEquation_example
ode_rober = ODEFunction(rober, mass_matrix = M)
u0 = [1.0,0.0,0.0]; # an inital condition which fulfills the constraint

g_rober = constraint_equations(ode_rober) # acsessing the constraint equation
g_rober(u0)
```

Randomly perturbing all varibales

```@example DifferentialEquation_example
Frand = random_force(ode_rober, [0.0,1], Uniform)
z_new = ambient_forcing(ode_rober, u0, 2.0, Frand)
g_rober(z_new) # g_rober(z_new) ≈ 0 means the the constraint is fulfilled
```

only perturbing the second variable y₂

```@example DifferentialEquation_example
h = [0, 1 ,0]
z_new = ambient_forcing(ode_rober, u0, 2.0, h)
g_rober(z_new)
```

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

