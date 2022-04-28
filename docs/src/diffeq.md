#DifferentialEquations.jl Example

This example shows the basic usage of the AmbientForcing and DifferentialEquation.jl.
We adopt the [Robertson Example](https://diffeq.sciml.ai/stable/tutorials/dae_example/) from the DifferentialEquation Docs.

We begin by load all necessary deps:
````@example diffeq_example
using AmbientForcing, Distributions, OrdinaryDiffEq
````

Then we define our differential equation:
````@example diffeq_example
function rober(du, u, p, t)
    y₁, y₂, y₃ = u
    du[1] = -0.04 * y₁ + 1e4 * y₂ * y₃
    du[2] = 0.04 * y₁ - 1e4 * y₂ * y₃ - 3e7 * y₂^2
    du[3] = y₁ + y₂ + y₃ - 1
    nothing
end
````
We create the mass matrix $M$, the last row depicts our constraint:
````@example diffeq_example
M = [1.0 0 0
    0 1.0 0
    0 0 0]
````
We set up the DAE as an ODE in mass matrix form:
````@example diffeq_example
ode_rober = ODEFunction(rober, mass_matrix=M)
````
We have to choose an initial condition which fulfills the constraints:
````@example diffeq_example
u0 = [1.0, 0.0, 0.0]
g_rober = constraint_equations(ode_rober)
isapprox(sum(g_rober(u0)), 0.0, atol=1e-8)
````
---

Using Ambient Forcing we randomly perturb all variables:
````@example diffeq_example
Frand = random_force(ode_rober, [0.0, 1], Uniform)
afoprob_rober = ambient_forcing_problem(ode_rober, u0, 2.0, Frand)
z_new_all = ambient_forcing(afoprob_rober, Frand)
isapprox(sum(g_rober(z_new_all)), 0.0, atol=1e-8)
````

---

Only perturbing the second variable $y_2$ works as well:
````@example diffeq_example
h = [0, 1, 0]
z_new_2 = ambient_forcing(afoprob_rober, h)
isapprox(sum(g_rober(z_new_2)), 0.0, atol=1e-8)
````