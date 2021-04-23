# AmbientForcing.jl Documentation

```@meta
CurrentModule = AmbientForcing
```

## Introduction
Differential algebraic equations (DAEs) consist of differential equations $f$ and algebraic equations, or constraints $g$.

```math
\begin{align}
        \dot{x} &= f(t, x(t),y(t))\\ 
        0 &= g(t, x(t), y(t)) = g(z)
    \end{align}
```
To solve these equations the problem is separated into two parts: finding valid initial conditions $(x_0,y_0,t_0)$ and calculating the trajectories .
Different DAE initialization methods have been implemented and are used in various differential equation solvers. 

Established initialization methods, like Brown's method, which is also included in \texttt{DifferentialEquations.jl}, can not be used to initalize localized Pertubations, needed for Single Node Basin Stability, since only a part of the system is initialized, and it is not possible to regulate what happens to the other variables during the initialization process. Thus it can not be controlled if a perturbation is only targeted to a single node.
This package offers an novel algorithm, called Ambient Forcing, to calulate valid localized iital conditions for DAE systems.

The center of the alogirtihm is solving the following differential equation, to generate new initial states. 
It is based on a theorem form Differentail Geometry that holds for smooth manifolds. 

Where $\dot z = h(z)$ is an arbitrary dynamic  the manifold preserving version can simply defined as:

For an arbitrary dynamic $\dot z = h(z)$ the manifold preserving version can simply defined as:

```math
    \begin{align}
        \dot z = P^\mathcal{N}(z) h(z)
    \end{align}
```
Where P^\mathcal{N}(z) is a projection matrix.

```@docs
ambient_forcing
```

Generally the constraint manifolds of power grids, which are given by the algebraic loads, are smooth.