# AmbientForcing

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://pik-icone.github.io/AmbientForcing.jl/dev/)

A package that can calculate valid initial conditions for differential-algebraic equations (DAEs) in mass matrix form.
The solutions of DAEs lie on constraint manifolds and not every state is valid anymore. Using the ambient forcing algorithm it is possible to calculate new valid states on the manifold.
It can especially be useful when one wants to perturb single variables of a system. 

This is, for example, needed when one wants to calculate the Single Node Basin of a power grid with loads.
The package can be used with any ODEFunction in mass matrix form but it is especially useful in combination with [NetworkDynamics.jl](https://github.com/PIK-ICoNe/NetworkDynamics.jl) or [PowerDynamics.jl](https://github.com/JuliaEnergy/PowerDynamics.jl).

The paper which explains Ambient Forcing in depth is accessible under the [DOI](https://iopscience.iop.org/article/10.1088/1367-2630/ac6822).

Check out the docs for more info on the package and some examples.