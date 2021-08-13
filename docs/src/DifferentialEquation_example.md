```@meta
EditURL = "<unknown>/../examples/DifferentialEquation_example.jl"
```

```@example DifferentialEquation_example
using AmbientForcing
using OrdinaryDiffEq, Distributions
```

Adopting the Robertson Example from the DifferentialEquation Docs
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

Creating the mass matrix M
The last row depicts our constraint

```@example DifferentialEquation_example
M = [1. 0  0
     0  1. 0
     0  0  0];
nothing #hide
```

Setting up the DAE as an ODE in mass matrix form

```@example DifferentialEquation_example
ode_rober = ODEFunction(rober, mass_matrix = M)
```

Choosing an inital condition which fulfills the constraint

```@example DifferentialEquation_example
u0 = [1.0,0.0,0.0];
nothing #hide
```

Acsessing the constraint equations g

```@example DifferentialEquation_example
g_rober = constraint_equations(ode_rober)
g_rober(u0)
```

Randomly perturbing all variables

```@example DifferentialEquation_example
Frand = random_force(ode_rober, [0.0,1], Uniform)
z_new = ambient_forcing(ode_rober, u0, 2.0, Frand)
```

g ≈ 0 means the constraint is fulfilled

```@example DifferentialEquation_example
g_rober(z_new)
```

Only perturbing the second variable y₂

```@example DifferentialEquation_example
h = [0, 1 ,0]
z_new = ambient_forcing(ode_rober, u0, 2.0, h)

g_rober(z_new)
```

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

