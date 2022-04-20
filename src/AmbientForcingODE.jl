using Symbolics
using LinearAlgebra
using OrdinaryDiffEq: Tsit5, solve, ODEProblem, ODEFunction, remake
using ForwardDiff: jacobian!


"""
    function ambient_forcing(f::ODEProblem, z, tau, Frand)

    Solves a given Ambient Forcing ODEProblem with initial condition z,
    end time tau and ambient vector Frand.

"""
function ambient_forcing(afoprob::ODEProblem, z, tau, Frand)
    !(typeof(afoprob.f.f) <: AmbientForcingODE) && error("Expected an AmbientForcingODE.")
    return solve(remake(afoprob, u0=z, tspan=(0.0, tau), p=Frand),
        Tsit5(), save_everystep=false, save_start=false)[end]
end

"""
    function ambient_forcing(f::ODEProblem,  Frand)

    Solves a given Ambient Forcing ODEProblem with ambient vector Frand.

"""
function ambient_forcing(afoprob::ODEProblem, Frand)
    !(typeof(afoprob.f.f) <: AmbientForcingODE) && error("Expected an AmbientForcingODE.")
    return solve(remake(afoprob, p=Frand),
        Tsit5(), save_everystep=false, save_start=false)[end]
end

"""
    constraint_equations(f::ODEFunction)
Returns the constraint equations from an ODEFunction f used in DifferentialEquations.jl.
f must be in Mass Matrix form meaning: M ẋ = f(x), with M diagonal.
f should be inplace.
"""
function constraint_equations(f::ODEFunction, p=nothing)
    M = f.mass_matrix
    M == I && error("There are no constraints in the system!")
    M != Diagonal(M) && error("The constraints are not diagonal.")
    cidx = findall(diag(M) .== 0)
    g(x) = (dx = similar(x);
    f(dx, x, p, 0.0);
    dx[cidx])
    return g
end

"""
    constrained_jac_from_f(f::ODEFunction, dim, const_idx)

    Returns a mutating functions (_out,u) that writes
    the Jacobian of the constraint equations of f at u into
    the Matrix _out. Uses Symbolics.jl
"""
function constrained_jac_from_f(f::ODEFunction, dim, cidx)
    @variables usym[1:dim]
    @variables _dusym[1:dim]
    dusym = collect(_dusym)
    f(dusym, collect(usym), nothing, 0.0) # mutate dusym
    duconst = simplify.(dusym[cidx])
    # This builds a jacobian (could be sparse?)
    # [!] We should offer an option for parameters
    symjac = Symbolics.jacobian(duconst, collect(usym))
    return Symbolics.build_function(symjac, usym, expression=Val{false})[2]
end


"""
    constrained_jac_from_f_fd(f::ODEFunction)

    Returns a mutating functions (_out,u) that writes
    the Jacobian of the constraint equations of f at u into
    the Matrix _out. Uses ForwardDiff.jl
"""
function constrained_jac_from_fd(f::ODEFunction)
    # [!] We should offer an option for parameters
    g = constraint_equations(f)
    return (_out, u) -> jacobian!(_out, g, u)
end


"""
    function ambient_forcing_problem(f::ODEFunction, z, tau, Frand)

    Returns an AmbientForcingProblem for a given constraint ODE function f.
    z is an initial condition that fulfills the constraints, tau is the
    integration period for the ambient forcing algorithm, Frand is a random 
    direction from the ambient space.

    The AmbientForcingODE describes the evolution of trajectories in 
    the constant vector field Frand projected onto the tangential bundle 
    of the constraint manifold.

    Throws an error if f has no constraints in
    mass_matrix form or if the mass_matrix is not diagonal.
"""
function ambient_forcing_problem(f::ODEFunction, z, tau, Frand; method = :Symbolics)
    # Check for consistent constraints
    M = f.mass_matrix
    M == I && error("There are no constraints in the system!")
    M != Diagonal(M) && error("The constraints are not diagonal.")
    dim = size(M, 1)
    cidx = findall(diag(M) .== 0)
    cdim = length(cidx)
    if method == :Symbolics
        fjac = constrained_jac_from_f(f, dim, cidx)
    elseif method == :ForwardDiff
        fjac = constrained_jac_from_fd(f)
    else
        error("Invalid differentiation method specified: $(method).")
    end
    # Initialize the buffers for the Jacobian of the constraints J
    # and the intermediate vectors
    J = similar(Frand, cdim, dim)
    invJJT = similar(Frand, cdim, cdim)
    buff1 = similar(Frand, cdim)
    buff2 = similar(Frand, cdim)
    nafo = AmbientForcingODE(fjac, J, invJJT, buff1, buff2)
    prob = ODEProblem(nafo, z, (0.0, tau), Frand)
    return prob
end


"""
    struct AmbientForcingODE{T,S}

    fjac is a function returning the Jacobian matrix of the constraint equations
    at a point u_0. J, invJJT, buff1, buff2 are buffers needed for the projection.

"""
struct AmbientForcingODE{T,S}
    fjac::T
    J::Matrix{S}
    invJJT::Matrix{S}
    buff1::Vector{S}
    buff2::Vector{S}
end

"""
    function (afo::AmbientForcingODE)(du, u, Frand, t)

    Computes the projection of Frand onto the nullspace of 
    the Jacobian afo.J at u by evaluating

    `(I - J^T * inv(J * J^T) * J) * Frand`

    and storing it in du.
    
    Since manifolds have the same dimension everywhere the inverse
    in this product should exist.
"""
function (afo::AmbientForcingODE)(du, u, Frand, t)
    # Evaluate Jacobian at u and save into J
    afo.fjac(afo.J, u) # add (p,t)?
    afo.invJJT .= inv(afo.J * transpose(afo.J))
    # Allocation free matrix multiply
    mul!(afo.buff1, afo.J, Frand)
    mul!(afo.buff2, afo.invJJT, afo.buff1)
    # Next two lines are du = Frand - J^T * buff2
    du .= Frand
    mul!(du, transpose(afo.J), afo.buff2, -1.0, 1)
    return nothing
end