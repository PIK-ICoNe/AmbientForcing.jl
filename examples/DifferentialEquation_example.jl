using AmbientForcing
using OrdinaryDiffEq, Distributions

# Adopting the Robertson Example from the DifferentialEquation Docs
# https://diffeq.sciml.ai/stable/tutorials/dae_example/
function rober(du, u, p, t)
  y₁, y₂, y₃ = u
  du[1] = -0.04 * y₁ + 1e4 * y₂ * y₃
  du[2] = 0.04 * y₁ - 1e4 * y₂ * y₃ - 3e7 * y₂^2
  du[3] = y₁ + y₂ + y₃ - 1
  nothing
end

# Creating the mass matrix M
# The last row depicts our constraint
M = [1.0 0 0;
  0 1.0 0;
  0 0 0]

# Setting up the DAE as an ODE in mass matrix form
ode_rober = ODEFunction(rober, mass_matrix=M)

# Choosing an inital condition which fulfills the constraint
u0 = [1.0, 0.0, 0.0];


# Randomly perturbing all variables  
Frand = random_force(ode_rober, [0.0, 1], Uniform)
afoprob = ambient_forcing(ode_rober, u0, 2.0, Frand)
z_new = solve(afoprob, Tsit5(), save_everystep = false, save_start=false)

# g ≈ 0 means the constraint is fulfilled
sum(z_new) - 1

# Only perturbing the second variable y₂
h = [0, 1, 0]
z_new = solve(remake(afoprob, p = h), Tsit5())[end]

sum(z_new) - 1