using Symbolics
using LinearAlgebra


"""
    constrained_jac_from_f(f::ODEFunction)

    Returns a mutating functions (_out,u) that writes
    the Jacobian of the constraint equations of f at u into
    the Matrix _out. 
"""
function constrained_jac_from_f(f::ODEFunction, dim, const_idx)
    # Create symbolic vectors for states and derivatives
    @variables usym[1:dim]
    @variables _dusym[1:dim]
    dusym = collect(_dusym)
    f(dusym, collect(usym), nothing, 0.0) # mutate dusym
    duconst = simplify.(dusym[const_idx])
    # This builds a jacobian (could be sparse?)
    # [!] We should offer an option for parameters
    symjac = Symbolics.jacobian(duconst, collect(usym))
    return Symbolics.build_function(symjac, usym, expression=Val{false})[2]
end

"""
Throws an error if f has no constraints in
    mass_matrix form or if the mass_matrix is not diagonal.
"""
function ambient_forcing(f::ODEFunction, z, tau, Frand)
    # Check for consistent constraints
    M = f.mass_matrix
    M == I && error("There are no constraints in the system!")
    M != Diagonal(M) && error("The constraints are not diagonal.")
    dim = size(M, 1)
    cidx = findall(diag(M) .== 0)
    cdim = length(cidx)
    # [!] We could offer different methods based on Symbolics or ForwardDiff
    fjac = constrained_jac_from_f(f, dim, cidx)
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

    at stores it in du.
    
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
    mul!(du, transpose(afo.J), afo.buff2, -1., 1)
    return nothing
end