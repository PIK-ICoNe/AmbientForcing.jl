"""
Calculates and returns the constraint equations from an ODEFunction used in
DifferentialEquations.jl.
The system must be in Mass Matrix form meaning: M ẋ = f(x). The constraints can
therefore be easily extracted by finding the diagonal entries of M which are 0.
Inputs:
       f: An ODEFunction in mass matrix form
Outputs:
        g(x): A function which holds all the constraints of f.

"""
function constraint_equations(f::ODEFunction)
    M = f.mass_matrix
    len_M = size(M, 1)
    g_idx = findall([M[i,i] for i in 1:len_M] .== 0)
    g(x) = (dx = similar(x);
            f(dx, x, nothing, 0.0);
            dx[g_idx])
end

"""
In DAE Problems not all initial conditions are valid. They lay on a constraint Manifold M.
This method can draw random initial condition form the constraint manifold M.
Here we sample values by using the AmbientForcing algorithm.
This consists of the following steps:
    1. Draw a random vector Frand from the ambient space
    2. Projetion back onto the tangetial space TxM by using PN

Inputs:
    f: An ODEFunction in mass matrix form
    initial_con: A point which lays on the manifold M, could e.g. be a fixed point
    dist_args: Arguments of the distribution function dist
    dist: Distribution function e.g. Uniform, Normal....
    tau: Integration time

Outputs:
    sol: Set of random initial condtions on M
"""
function AmbientForcing(f::ODEFunction, z, tau, Frand)
    g = constraint_equations(f)
    prob = ODEProblem(ambient_forcing_ODE, z, (0.0, tau), (g, Frand))
    sol = solve(prob)
    return sol
end

"""
Calculates the orthogonal projection on a subspace N. The basis of N does not
have to be a orthonormal basis. The matrix (A^T*A)^-1 recovers the norm.
Inputs:
A: Matrix containg the basis vectors of a subspace N as columns
"""
Proj_N(A) = A * inv(transpose(A) * A) * transpose(A)

"""
Takes a constraint function g and a random value Frand form the ambient space 
and calculates the projection on to the tangetial space. This gives a manifold
preserving version of any dynamic.
ż = Pn(ker(Jg)) * Frand
This is an ODE which will be solved using DifferentialEquations.jl
Inputs:
p[1] = g: The function defining the manifold
p[2] = Frand: A random, constant vector from ambient space
u0: Inital condition
t: Integration time
"""
function ambient_forcing_ODE(u, p, t)
    g, Frand = p
    Jacg = ForwardDiff.jacobian(g, u)
    N = nullspace(Jacg)
    du = Proj_N(N) * Frand # Projection back onto the Manifold
end
