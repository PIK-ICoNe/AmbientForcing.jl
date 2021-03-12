"""
    constraint_equations(f::ODEFunction)

Returns the constraint equations from an ODEFunction f used in DifferentialEquations.jl.

f must be in Mass Matrix form meaning: M ẋ = f(x).
"""
function constraint_equations(f::ODEFunction)
    M = f.mass_matrix
    if M == true*I
        error("There are no constraints in the system!")
    end
    len_M = size(M, 1)
    g_idx = findall([M[i,i] for i in 1:len_M] .== 0)
    g(x) = (dx = similar(x);
            f(dx, x, nothing, 0.0);
            dx[g_idx])
end

"""
    AmbientForcing(f::ODEFunction, z, tau, Frand)
Draws random initial condition form the constraint manifold M.

This consists of the following steps:
    1. Draw a random vector Frand from the ambient space
    2. Projetion back onto the tangetial space TxM by using PN

# Arguments
    f: An ODEFunction in mass matrix form
    initial_con: A point which lays on the manifold M, could e.g. be a fixed point
    dist_args: Arguments of the distribution function dist
    dist: Distribution function e.g. Uniform, Normal....
    tau: Integration time
"""
function ambient_forcing(f::ODEFunction, z, tau, Frand)
    g = constraint_equations(f)
    prob = ODEProblem(ambient_forcing_ODE, z, (0.0, tau), (g, Frand))
    sol = solve(prob, Tsit5())
    return sol[end]
end

"""
    Proj_N(A)

Calculates the orthogonal projection matrix on a subspace N.

A is a matrix containg the basis vectors of N as columns.
The matrix (A^T*A)^-1 recovers the norm.
"""
Proj_N(A) = A * inv(transpose(A) * A) * transpose(A)

"""
    ambient_forcing_ODE(u, p, t)
The manifold preserving ODE version of a vector h.

ż = Pn(ker(Jg)) * h
# Arguments
    `p[1]`: g the function defining the manifold
    `p[2]` h constant vector from ambient space
    `u0`: Inital condition
    `t`: Integration time
"""
function ambient_forcing_ODE(u, p, t)
    g, h = p
    Jacg = jacobian(g, u)
    N = nullspace(Jacg)
    du = Proj_N(N) * h # Projection back onto the Manifold
end
