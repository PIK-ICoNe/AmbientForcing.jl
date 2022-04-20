```@meta
EditURL = "<unknown>/examples/NetworkDynamics_example.jl"
```

````@example NetworkDynamics_example
using AmbientForcing
using NetworkDynamics, Distributions
using Graphs
using OrdinaryDiffEq
````

This is an example from NetworkDynamics
https://github.com/PIK-ICoN/NetworkDynamics.jl/blob/master/examples/kuramoto_plasticity.jl
This only works with NetworkDynamics v0.5.0 or newer

Further examples can be found in the test folder

````@example NetworkDynamics_example
const N_plastic = 10 # number of nodes
k = 4  # average degree
g = barabasi_albert(N_plastic, k)
````

  Berner, Rico, Eckehard Schöll, and Serhiy Yanchuk.
  "Multiclusters in Networks of Adaptively Coupled Phase Oscillators."
  SIAM Journal on Applied Dynamical Systems 18.4 (2019): 2227-2266.

The coupling function is modeled by a differential algebraic equation with mass matrix
0 * de[1] = e[2] * sin(v_s[1] - v_d[1] + α) / N - e[1] is equivalent to
e[1] = e[2] * sin(v_s[1] - v_d[1] + α) / N

````@example NetworkDynamics_example
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
````

Global parameters need to be const for type stability

````@example NetworkDynamics_example
const ϵ = 0.1
const α = .2π
const β = -.95π
````

NetworkDynamics Setup

````@example NetworkDynamics_example
plasticvertex = ODEVertex(f = kuramoto_plastic_vertex!, dim =1)
mass_matrix_plasticedge = zeros(2,2)
mass_matrix_plasticedge[2,2] = 1. # First variables is set to 0

plasticedge = ODEEdge(f = kuramoto_plastic_edge!, dim=2, sym=[:e, :de], coupling=:undirected,mass_matrix = mass_matrix_plasticedge);
kuramoto_plastic! = network_dynamics(plasticvertex, plasticedge, g)
````

Ambient Forcing starts here

Using a random initial condition x0 violates the constraints!
The constraints are fulfilled when g(x) ≈ 0.

````@example NetworkDynamics_example
x0_plastic = rand(106)
g_nd = constraint_equations(kuramoto_plastic!)
sum(g_nd(x0_plastic))
````

Using zeros as the initial conditions for the ambient forcing algo

````@example NetworkDynamics_example
x0_plastic = zeros(106)
g_nd = constraint_equations(kuramoto_plastic!)
g_nd(x0_plastic)
````

Perturbing all variables at once

````@example NetworkDynamics_example
Frand = random_force(kuramoto_plastic!, [0.0, 1.0], Uniform)
afoprob = ambient_forcing_problem(kuramoto_plastic!, x0_plastic, 2.0, Frand)
z_new = ambient_forcing(afoprob, x0_plastic, 2.0, Frand)
````

As we can see the constraints are not violated!

````@example NetworkDynamics_example
sum(g_nd(z_new))
````

Perturbing only the variables e_22 and de_22

````@example NetworkDynamics_example
idx = idx_exclusive(kuramoto_plastic!, ["e_22", "de_22"])
Frand = random_force(kuramoto_plastic!, [0.0, 1.0], Uniform, idx)
z_new = ambient_forcing(afoprob, x0_plastic, 2.0, Frand)
````

Still the constraints are fulfilled!

````@example NetworkDynamics_example
sum(g_nd(z_new))
````

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

