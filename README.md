# AmbientForcing

A package which is able to calculate valid initial conditions for differential algebraic equation (DAEs) in mass matrix form.
The solutions of DAEs lie on constraint manifolds and not every state is valid anymore. Using the ambient forcing algorithm it is possible to calculate new valid states on the manifold.
It can especially be useful when one wants to perturb single variables of a system. 

This is, for example, needed when one wants to calculate the Single Node Basin of a power grid with constraints.
The package an be used with any ODEFunction in mass matrix form but it is especially useful in combination with [NetworkDynamics.jl](https://github.com/PIK-ICoN/NetworkDynamics.jl) or [PowerDynamics.jl](https://github.com/JuliaEnergy/PowerDynamics.jl).

To get started go to the example folder to find three different examples.