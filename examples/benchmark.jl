using AmbientForcing
using OrdinaryDiffEq
using Test
using LinearAlgebra

using BenchmarkTools


# Simple spherical dynamics

function g(du, u, p, t)
    du .= 0
    du[1] = 1.0
    du[end] = 1.0 - sum(u .^ 2)
    return nothing
end

N = 100
M = Diagonal([ones(N - 1); zeros(1)])
u0 = [zeros(N - 1); 1.0]
Frand = [1.0; zeros(N - 1)]


odeg = ODEFunction(g, mass_matrix=M)
prob = ODEProblem(odeg, u0, (0.0, 1.0))

solve(prob, Rodas4())
afoprob = ambient_forcing_problem(odeg, u0, 10.0, Frand)
sol = solve(afoprob, Tsit5(), save_everystep=false)
@btime solve(afoprob, Tsit5(), save_everystep=false)

afoprob_fd = ambient_forcing_problem(odeg, u0, 10.0, Frand, method=:ForwardDiff)
sol_fd = solve(afoprob_fd, Tsit5(), save_everystep=false)
@btime solve(afoprob_fd, Tsit5(), save_everystep=false)

@test Array(sol) == Array(sol_fd)