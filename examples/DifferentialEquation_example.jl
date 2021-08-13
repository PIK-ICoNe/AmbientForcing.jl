using AmbientForcing
using OrdinaryDiffEq, Distributions

# Adopting the Robertson Example from the DifferentialEquation Docs
# https://diffeq.sciml.ai/stable/tutorials/advanced_ode_example/#Handling-Mass-Matrices
function rober(du,u,p,t)
  y₁,y₂,y₃ = u
  du[1] = -0.04 * y₁ + 1e4 * y₂ * y₃
  du[2] =  0.04 * y₁ - 1e4 * y₂ * y₃ - 3e7 * y₂^2
  du[3] =  y₁ + y₂ + y₃ - 1
  nothing
end

# Creating the mass matrix M
# The last row depicts our constraint
M = [1. 0  0
     0  1. 0
     0  0  0];

# Setting up the DAE as an ODE in mass matrix form
ode_rober = ODEFunction(rober, mass_matrix = M) 

# Choosing an inital condition which fulfills the constraint
u0 = [1.0,0.0,0.0]; 

# Acsessing the constraint equations g
g_rober = constraint_equations(ode_rober) 
g_rober(u0)

# Randomly perturbing all variables  
Frand = random_force(ode_rober, [0.0,1], Uniform)
z_new = ambient_forcing(ode_rober, u0, 2.0, Frand)

# g ≈ 0 means the constraint is fulfilled
g_rober(z_new) 

# Only perturbing the second variable y₂
h = [0, 1 ,0]
z_new = ambient_forcing(ode_rober, u0, 2.0, h)

g_rober(z_new)