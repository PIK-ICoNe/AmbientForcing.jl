using AmbientForcing
using PowerDynamics, Distributions
using OrdinaryDiffEq
using Test

@testset "PD_example" begin
    # Lets create a small test power grid with three nodes
    line_list = []
    append!(line_list, [StaticLine(from=1, to=2, Y=-1im / 0.02 + 4)])
    append!(line_list, [StaticLine(from=1, to=3, Y=-1im / 0.02 + 4)])


    # The PQAlgebraic Node is our constraint. The Power Output of node 3 is fixed.
    node_list = []
    append!(node_list, [SlackAlgebraic(U=1, Y_n=0)])
    append!(node_list, [FourthOrderEq(H=3.318, P=-0.6337, D=0.1, Ω=50, E_f=0.5, T_d_dash=0.1, T_q_dash=8.690, X_d_dash=0.111, X_q_dash=0.103, X_d=0.1, X_q=0.6)])
    append!(node_list, [PQAlgebraic(P=-0.6337, Q=0.0)])

    # Using the right hand side as our ODEFunction
    pg = PowerGrid(node_list, line_list)
    rpg = rhs(pg)

    # Accessing the constraint equation g of the power grid
    g = constraint_equations(rpg)

    # The operation point is a fixed point and naturally lies on the manifold
    # Thus it can be used as the initial condition for our differential equation
    op = find_operationpoint(pg)

    # Lets check if g(op) ≈ 0 meaning that the constraint is fulfilled
    @test isapprox(sum(g(op.vec)), 0.0, atol=1e-8)


    # Lets generate a random vector from the ambient space
    # First we want to perturb all variables in the grid
    Frand = random_force(rpg, [0.0, 1], Uniform)
    afoprob = ambient_forcing_problem(rpg, op.vec, 2.0, Frand, method=:ForwardDiff)
    z_new_all = ambient_forcing(afoprob, op.vec, 2.0, Frand) # Our new valid initial condition
    @test isapprox(sum(g(z_new_all)), 0.0, atol=1e-8)

    ## Next: let's perturb just the voltage at node 3!
    # Getting the index of the real and imaginary part of the voltage

    idx = idx_exclusive(rpg, ["u_r_3", "u_i_3"])
    # generate a vector only with non-vanishing components the voltage at node 3
    Frand = random_force(rpg, [0.0, 1.0], Uniform, idx)
    z_new_node_3 = ambient_forcing(afoprob, Frand)
    @test isapprox(sum(g(z_new_node_3)), 0.0, atol=1e-8)


    # It is also possible to perturb the variable using different distributions:
    # Typically SNBS the angle θ and ω are perturbed differently
    idx = idx_exclusive(rpg, ["u_r_2", "u_i_2", "θ_2", "ω_2"])
    τ = 2.0 # the integration time

    # When you want to sample eg. the angle θ from a box of [0, 2π] 
    # You have to make sure to dived the distribution argument by the integration time τ
    dist_vec = [[0, 1], [0, 2], [0, 2π] ./ τ, [-5, 5] ./ τ]

    Frand = random_force(rpg, dist_vec, Uniform, idx)
    z_new_node_2 = ambient_forcing(afoprob, op.vec, τ, Frand)
    @test isapprox(sum(g(z_new_node_2)), 0.0, atol=1e-8)
end

@testset "OrdinaryDiffEq_example" begin
    # Adopting the Robertson Example from the DifferentialEquation Docs
    # https://diffeq.sciml.ai/stable/tutorials/dae_example/
    function rober(du, u, p, t)
        y₁, y₂, y₃ = u
        du[1] = -0.04 * y₁ + 1e4 * y₂ * y₃
        du[2] = 0.04 * y₁ - 1e4 * y₂ * y₃ - 3e7 * y₂^2
        du[3] = y₁ + y₂ + y₃ - 1
        nothing
    end

    # Creating the mass matrix M
    # The last row depicts our constraint
    M = [1.0 0 0
        0 1.0 0
        0 0 0]

    # Setting up the DAE as an ODE in mass matrix form
    ode_rober = ODEFunction(rober, mass_matrix=M)

    # Choosing an inital condition which fulfills the constraint
    u0 = [1.0, 0.0, 0.0]

    g_rober = constraint_equations(ode_rober)
    @test isapprox(sum(g_rober(u0)), 0.0, atol=1e-8)

    # Randomly perturbing all variables  
    Frand = random_force(ode_rober, [0.0, 1], Uniform)
    afoprob_rober = ambient_forcing_problem(ode_rober, u0, 2.0, Frand)
    z_new_all = ambient_forcing(afoprob_rober, Frand)
    @test isapprox(sum(g_rober(z_new_all)), 0.0, atol=1e-8)

    # only perturbing the second variable y₂
    h = [0, 1, 0]
    z_new_2 = ambient_forcing(afoprob_rober, h)
    @test isapprox(sum(g_rober(z_new_2)), 0.0, atol=1e-8)
end