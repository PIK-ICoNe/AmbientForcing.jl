#NetworkDynamics.jl Example

This example shows the basic usage of AmbientForcing.jl and [NetworkDynamics.jl](https://github.com/PIK-ICoNe/NetworkDynamics.jl). It is adopted from the [Network Dynamics Docs](https://github.com/PIK-ICoN/NetworkDynamics.jl/blob/master/examples/kuramoto_plasticity.jl).
This example only works with NetworkDynamics v0.5.0 or newer.

----
We begin with the NetworkDynamics Setup. First we include all necessary packages.
````@example NetworkDynamics_example
using AmbientForcing
using NetworkDynamics, Distributions
using Graphs
using OrdinaryDiffEq
````
We generate a random graph with 10 nodes and an average degree of 4.

````@example NetworkDynamics_example
const N_plastic = 10 # number of nodes
k = 4  # average degree
g = barabasi_albert(N_plastic, k)
````
The coupling function is modeled by a differential algebraic equation with mass matrix:

$0 \cdot \frac{de_1}{dt} = e_2 \cdot \frac{sin(v_{s1} - v_{d1} + α)}{N} - e_1$ 
which is equivalent to:
$e_1 = e_2 \cdot \frac{sin(v_{s1} - v_{d1} + α)}{N}$

This model comes from the following publication: 
R. Berner et. al., "Multiclusters in Networks of Adaptively Coupled Phase Oscillators." SIAM Journal on Applied Dynamical Systems 18.4 (2019): 2227-2266.

In NetworkDynamics.jl we define the edge dynamics as following:

````@example NetworkDynamics_example
function kuramoto_plastic_edge!(de, e, v_s, v_d, p, t)
    de[1] =  e[2] * sin(v_s[1] - v_d[1] + α) / N_plastic - e[1]
    de[2] = - ϵ * (sin(v_s[1] - v_d[1] + β) + e[2])

    nothing
end
````
and the node dynamics as:
````@example NetworkDynamics_example
function kuramoto_plastic_vertex!(dv, v, edges, p, t)
    dv .= 0
    for e in edges
        dv .-= e[1]
    end
end
````

We define the following constants:
````@example NetworkDynamics_example
const ϵ = 0.1
const α = .2π
const β = -.95π
````

Then we generate a network dynamics problem:
````@example NetworkDynamics_example
plasticvertex = ODEVertex(f = kuramoto_plastic_vertex!, dim =1)
mass_matrix_plasticedge = zeros(2,2)
mass_matrix_plasticedge[2,2] = 1. # First variables is set to 0

plasticedge = ODEEdge(f = kuramoto_plastic_edge!, dim=2, sym=[:e, :de], coupling=:undirected,mass_matrix = mass_matrix_plasticedge);
kuramoto_plastic! = network_dynamics(plasticvertex, plasticedge, g)
````
-------
The Ambient Forcing part starts here!

Using a random initial condition x0 violates the constraints! The constraints are fulfilled when $g(x) ≈ 0$.

````@example NetworkDynamics_example
x0_plastic = rand(106)
g_nd = constraint_equations(kuramoto_plastic!)
sum(g_nd(x0_plastic))
````

We use zeros as the initial conditions for the ambient forcing algo and access the constraint equation $g$:
````@example NetworkDynamics_example
x0_plastic = zeros(106)
g_nd = constraint_equations(kuramoto_plastic!)
g_nd(x0_plastic)
````
This point fulfills the constraints and we can use it as the initial condition for Ambient Forcing.

---

We start by perturbing all variables at once:

````@example NetworkDynamics_example
Frand = random_force(kuramoto_plastic!, [0.0, 1.0], Uniform)
afoprob = ambient_forcing_problem(kuramoto_plastic!, x0_plastic, 2.0, Frand)
z_new = ambient_forcing(afoprob, x0_plastic, 2.0, Frand)
````

As we can see the constraints are not violated!

````@example NetworkDynamics_example
sum(g_nd(z_new))
````

---

Now we only perturb the variables $e_{22}$ and $de_{22}$

````@example NetworkDynamics_example
idx = idx_exclusive(kuramoto_plastic!, ["e_22", "de_22"])
Frand = random_force(kuramoto_plastic!, [0.0, 1.0], Uniform, idx)
z_new = ambient_forcing(afoprob, x0_plastic, 2.0, Frand)
````

We can see that the constraints are fulfilled!

````@example NetworkDynamics_example
sum(g_nd(z_new))
````