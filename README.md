# AmbientForcing

A package which is able to calculate valid inital conditions for differential algebraic equation (DAEs) in mass matrix form.
The solutions of DAEs lie on constrint mainfolds and not every state is valid anymore. Using the ambient forcing alorithm it is possible to calulate new valid states on the manifold.
It can esspecially be useful when one wants to perrturb single variables of a system. 

This is, for example, needed when one wants to calculate the Single Node Basin of a power grid with constaints.
The package an be used with any ODEFunction in mass matrix form but it is especially useful in combination with [NetworkDynamics.jl](https://github.com/PIK-ICoN/NetworkDynamics.jl) or [PowerDynamics.jl](https://github.com/JuliaEnergy/PowerDynamics.jl).

## Example using PowerDynamics
First create a small power grid with two nodes.
```
using PowerDynamics

line_list = []
append!(line_list, [StaticLine(from = 1, to = 2, Y = -1im / 0.02 + 4)])

node_list = []
append!(node_list, [SlackAlgebraic(U = 1, Y_n = 0)])
append!(node_list, [FourthOrderEq(H = 3.318, P = -0.6337, D = 0.1, Ω = 50, E_f = 0.5, T_d_dash = 0.1,  T_q_dash = 8.690,X_d_dash = 0.111,  X_q_dash = 0.103, X_d = 0.1, X_q = 0.6)])

pg = PowerGrid(node_list, line_list)
rpg = rhs(pg) # get the rigth-hand-side as an ODEFunction
op = find_operationpoint(pg) # the fix point natrually lie on the manifold
```

Then all variables of the power grid can be perturbed:
```
using Distributions
Frand = random_force(rpg, [0.0,1], Uniform)
sol = ambient_forcing(rpg, op.vec, 2.0, Frand)
```

Or just the voltage of node 2:
```
idx = idx_exclusive(rpg, ["u_r_2", "u_i_2"])

Frand = random_force(rpg, [0.0, 1.0], Uniform, idx)

ambient_forcing(rpg, op.vec, 2.0, Frand)
```