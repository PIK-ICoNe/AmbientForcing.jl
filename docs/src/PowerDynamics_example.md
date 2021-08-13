```@meta
EditURL = "<unknown>/../examples/PowerDynamics_example.jl"
```

```@example PowerDynamics_example
using AmbientForcing
using PowerDynamics, Distributions
```

Lets create a small test power grid with three nodes

```@example PowerDynamics_example
line_list = []
append!(line_list, [StaticLine(from = 1, to = 2, Y = -1im / 0.02 + 4)])
append!(line_list, [StaticLine(from = 1, to = 3, Y = -1im / 0.02 + 4)])
```

The PQAlgebraic Node is our constraint. The Power Output of node 3 is fixed.

```@example PowerDynamics_example
node_list = []
append!(node_list, [SlackAlgebraic(U = 1, Y_n = 0)])
append!(node_list, [FourthOrderEq(H = 3.318, P = -0.6337, D = 0.1, Ω = 50, E_f = 0.5, T_d_dash = 0.1,  T_q_dash = 8.690,X_d_dash = 0.111,  X_q_dash = 0.103, X_d = 0.1, X_q = 0.6)])
append!(node_list, [PQAlgebraic(P = -0.6337, Q = 0.0)])
```

Using the rigth hand side as our ODEFunction

```@example PowerDynamics_example
pg = PowerGrid(node_list, line_list)
rpg = rhs(pg)
```

Acessing the constraint equation g of the power grid

```@example PowerDynamics_example
g = constraint_equations(rpg)
```

The operation point is a fixed point and naturally lies on the manifold
Thus it can be used as the initial condition for our differential equation

```@example PowerDynamics_example
op = find_operationpoint(pg)
```

Lets check if g(op) ≈ 0 meaning that the constraint is fulfilled

```@example PowerDynamics_example
g(op.vec)
```

Lets generate a random vector from the ambient space
First we want to perturb all variables in the grid

```@example PowerDynamics_example
Frand = random_force(rpg, [0.0,1], Uniform)
```

As we can see our new valid inital condition fulfills the constraints :-)

```@example PowerDynamics_example
z_new = ambient_forcing(rpg, op.vec, 2.0, Frand)
g(z_new)

# Next: let's perturb just the voltage at node 2!
```

Getting the index of the real and imaginary part of the voltage

```@example PowerDynamics_example
idx = idx_exclusive(rpg, ["u_r_2", "u_i_2"])
```

Now we generate a vector with only non-vanishing componants at the voltage of node 2

```@example PowerDynamics_example
Frand = random_force(rpg, [0.0, 1.0], Uniform, idx)
```

We solve the differential equation and find that the constraint remains fulfilled!

```@example PowerDynamics_example
z_new = ambient_forcing(rpg, op.vec, 2.0, Frand);
g(z_new)
```

It is also possible to perturb the variable using different distributions:
Typically SNBS the angle θ and ω are pertubed differently

```@example PowerDynamics_example
idx = idx_exclusive(rpg, ["u_r_2", "u_i_2", "θ_2", "ω_2"])
τ = 2.0 # the integration time
```

When you want to sample eg. the angle θ from a box of [0, 2π]
You have to make sure to devide the distribution argument by the integration time τ

```@example PowerDynamics_example
dist_vec = [[0,1], [0, 2], [0, 2π] ./τ, [-5, 5] ./τ]
```

Then everything works as beforehand. And we see again that we have created a valid initial condition!

```@example PowerDynamics_example
Frand = Frand = random_force(rpg, dist_vec, Uniform, idx)
z_new = ambient_forcing(rpg, op.vec, τ, Frand)
g(z_new)
```

---

*This page was generated using [Literate.jl](https://github.com/fredrikekre/Literate.jl).*

