# AmbientForcing

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://pik-icone.github.io/AmbientForcing.jl/dev/)

A package that can calculate valid initial conditions for differential-algebraic equations (DAEs) in mass matrix form.
The solutions of DAEs lie on constraint manifolds and not every state is valid anymore. Using the ambient forcing algorithm it is possible to calculate new valid states on the manifold.
It can especially be useful when one wants to perturb single variables of a system. 

This is, for example, needed when one wants to calculate the Single Node Basin of a power grid with loads.
The package can be used with any ODEFunction in mass matrix form but it is especially useful in combination with [NetworkDynamics.jl](https://github.com/PIK-ICoNe/NetworkDynamics.jl) or [PowerDynamics.jl](https://github.com/JuliaEnergy/PowerDynamics.jl).

Check out the docs for more info and some examples.

AmbientForcing.jl is not fully published yet. In order to use it you have to manually add it from GitHub!

```
julia> ] add "https://github.com/PIK-ICoNe/AmbientForcing.jl"
```