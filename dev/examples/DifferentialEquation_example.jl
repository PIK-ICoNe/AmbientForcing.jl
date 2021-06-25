using AmbientForcing
using OrdinaryDiffEq, Distributions

function rober(du,u,p,t)
    y₁,y₂,y₃ = u
    du[1] = -0.04 * y₁ + 1e4 * y₂ * y₃
    du[2] =  0.04 * y₁ - 1e4 * y₂ * y₃ - 3e7 * y₂^2
    du[3] =  y₁ + y₂ + y₃ - 1
    nothing
  end

  M = [1. 0  0
       0  1. 0
       0  0  0];

ode_rober = ODEFunction(rober, mass_matrix = M)
u0 = [1.0,0.0,0.0]; # an inital condition which fulfills the constraint

g_rober = constraint_equations(ode_rober) # acsessing the constraint equation
g_rober(u0)

Frand = random_force(ode_rober, [0.0,1], Uniform)
z_new = ambient_forcing(ode_rober, u0, 2.0, Frand)
g_rober(z_new) # g_rober(z_new) ≈ 0 means the the constraint is fulfilled

h = [0, 1 ,0]
z_new = ambient_forcing(ode_rober, u0, 2.0, h)
g_rober(z_new)

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

