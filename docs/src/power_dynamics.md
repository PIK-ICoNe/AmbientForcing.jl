#PowerDynamics.jl Example
This example shows the basic usage of the AmbientForcing and [PowerDynamics.jl](https://github.com/JuliaEnergy/PowerDynamics.jl).

We begin with the Setup. First we include all necessary packages.
````@example pd_example
using AmbientForcing
using PowerDynamics, Distributions
````

Lets create a small test power grid with three nodes:
````@example pd_example
line_list = []
append!(line_list, [StaticLine(from=1, to=2, Y=-1im / 0.02 + 4)])
append!(line_list, [StaticLine(from=1, to=3, Y=-1im / 0.02 + 4)])
````
The PQAlgebraic Node is our constraint. The Power Output of node 3 is fixed.
````@example pd_example
node_list = []
append!(node_list, [SlackAlgebraic(U=1, Y_n=0)])
append!(node_list, [FourthOrderEq(H=3.318, P=-0.6337, D=0.1, Ω=50, E_f=0.5, T_d_dash=0.1, T_q_dash=8.690, X_d_dash=0.111, X_q_dash=0.103, X_d=0.1, X_q=0.6)])
append!(node_list, [PQAlgebraic(P=-0.6337, Q=0.0)])
````
We use the right hand side as our ODEFunction
````@example pd_example
pg = PowerGrid(node_list, line_list)
rpg = rhs(pg)
````
We access the constraint equations $g$ of the power grid:
````@example pd_example    
g = constraint_equations(rpg)
````
The operation point is a fixed point and naturally lies on the manifold. Thus it can be used as the initial condition for AmbientForcing.
We can easily find the operation point using PowerDynamics in-build function:
````@example pd_example
op = find_operationpoint(pg)
````

Lets check if $g(op) ≈ 0$, which means that the constraint is fulfilled.
````@example pd_example
isapprox(sum(g(op.vec)), 0.0, atol=1e-8)
````

---

Lets generate a random vector from the ambient space. First we want to perturb all variables in the grid:
````@example pd_example
Frand = random_force(rpg, [0.0, 1], Uniform)
afoprob = ambient_forcing_problem(rpg, op.vec, 2.0, Frand, method=:ForwardDiff)
z_new_all = ambient_forcing(afoprob, op.vec, 2.0, Frand) # Our new valid initial condition
isapprox(sum(g(z_new_all)), 0.0, atol=1e-8)
````
---

Next: let's perturb just the voltage at node 3! We begin by getting the index of the real and imaginary part of the voltage:
````@example pd_example
idx = idx_exclusive(rpg, ["u_r_3", "u_i_3"])
````
Then we generate a vector only with non-vanishing components the voltage at node 3:
````@example pd_example
    Frand = random_force(rpg, [0.0, 1.0], Uniform, idx)
    z_new_node_3 = ambient_forcing(afoprob, Frand)
    isapprox(sum(g(z_new_node_3)), 0.0, atol=1e-8)
````

We see that the constraints are fulfilled.

---

It is also possible to perturb the variable using different distributions. Typically SNBS the angle θ and ω are perturbed differently:

````@example pd_example
idx = idx_exclusive(rpg, ["u_r_2", "u_i_2", "θ_2", "ω_2"])
τ = 2.0 # the integration time
````
When you want to sample the angle θ from a box of $[0, 2π]$. You have to make sure to dived the distribution argument by the integration time $τ$.
````@example pd_example
dist_vec = [[0, 1], [0, 2], [0, 2π] ./ τ, [-5, 5] ./ τ]

Frand = random_force(rpg, dist_vec, Uniform, idx)
z_new_node_2 = ambient_forcing(afoprob, op.vec, τ, Frand)
isapprox(sum(g(z_new_node_2)), 0.0, atol=1e-8)
````

Still we find a valid initial condition!