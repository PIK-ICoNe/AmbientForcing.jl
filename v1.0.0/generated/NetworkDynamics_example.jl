using AmbientForcing
using NetworkDynamics, Distributions
using Graphs
using OrdinaryDiffEq

const N_plastic = 10 # number of nodes
k = 4  # average degree
g = barabasi_albert(N_plastic, k)

function kuramoto_plastic_edge!(de, e, v_s, v_d, p, t)
    de[1] =  e[2] * sin(v_s[1] - v_d[1] + α) / N_plastic - e[1]
    de[2] = - ϵ * (sin(v_s[1] - v_d[1] + β) + e[2])

    nothing
end

function kuramoto_plastic_vertex!(dv, v, edges, p, t)
    dv .= 0
    for e in edges
        dv .-= e[1]
    end
end

const ϵ = 0.1
const α = .2π
const β = -.95π

plasticvertex = ODEVertex(f = kuramoto_plastic_vertex!, dim =1)
mass_matrix_plasticedge = zeros(2,2)
mass_matrix_plasticedge[2,2] = 1. # First variables is set to 0

plasticedge = ODEEdge(f = kuramoto_plastic_edge!, dim=2, sym=[:e, :de], coupling=:undirected,mass_matrix = mass_matrix_plasticedge);
kuramoto_plastic! = network_dynamics(plasticvertex, plasticedge, g)

x0_plastic = rand(106)
g_nd = constraint_equations(kuramoto_plastic!)
sum(g_nd(x0_plastic))

x0_plastic = zeros(106)
g_nd = constraint_equations(kuramoto_plastic!)
g_nd(x0_plastic)

Frand = random_force(kuramoto_plastic!, [0.0, 1.0], Uniform)
afoprob = ambient_forcing_problem(kuramoto_plastic!, x0_plastic, 2.0, Frand)
z_new = ambient_forcing(afoprob, x0_plastic, 2.0, Frand)

sum(g_nd(z_new))

idx = idx_exclusive(kuramoto_plastic!, ["e_22", "de_22"])
Frand = random_force(kuramoto_plastic!, [0.0, 1.0], Uniform, idx)
z_new = ambient_forcing(afoprob, x0_plastic, 2.0, Frand)

sum(g_nd(z_new))

# This file was generated using Literate.jl, https://github.com/fredrikekre/Literate.jl

