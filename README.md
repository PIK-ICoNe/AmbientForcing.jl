# AmbientForcing

A package which is able to calculate valid inital conditions for differential algebraic equation (DAEs) in mass matrix form.
The solutions of DAEs lie on constrint mainfolds and not every state is valid anymore. Using the ambient forcing alorithm it is possible to calulate new valid states on the manifold.
It can esspecially be useful when one wants to perrturb single variables of a system. 

This is, for example, needed when one wants to calculate the Single Node Basin of a power grid with constaints.
The package an be used with any ODEFunction in mass matrix form but it is especially useful in combination with [NetworkDynamics.jl](https://github.com/PIK-ICoN/NetworkDynamics.jl) or [PowerDynamics.jl](https://github.com/JuliaEnergy/PowerDynamics.jl).

To get started go to the example folder to find three different examples.
```