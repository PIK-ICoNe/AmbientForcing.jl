using AmbientForcing
using PowerDynamics, Distributions
using OrdinaryDiffEq
using Test

@testset "PD_example" begin
    line_list = []
    append!(line_list, [StaticLine(from = 1, to = 2, Y = -1im / 0.02 + 4)])
    append!(line_list, [StaticLine(from = 1, to = 3, Y = -1im / 0.02 + 4)])

    node_list = []
    append!(node_list, [SlackAlgebraic(U = 1, Y_n = 0)])
    append!(node_list, [FourthOrderEq(H = 3.318, P = -0.6337, D = 0.1, Ω = 50, E_f = 0.5, T_d_dash = 0.1,  T_q_dash = 8.690,X_d_dash = 0.111,  X_q_dash = 0.103, X_d = 0.1, X_q = 0.6)])
    append!(node_list, [PQAlgebraic(P = -0.6337, Q = 0.0)]) # This is our constraint

    pg = PowerGrid(node_list, line_list)
    rpg = rhs(pg)

    g = constraint_equations(rpg)
    op = find_operationpoint(pg) 
    @test isapprox(sum(g(op.vec)), 0.0, atol = 1e-8)

    Frand = random_force(rpg, [0.0,1], Uniform)
    z_new_all = ambient_forcing(rpg, op.vec, 2.0, Frand) # Our new valid inital condition
    @test isapprox(sum(g(z_new_all)), 0.0, atol = 1e-8)

    τ = 2.0 # the integration time
    idx = idx_exclusive(rpg, ["u_r_3", "u_i_3"]) 
    # genrate a vector only with non-vanishing componats the voltage at node 2
    Frand = random_force(rpg, [0.0, 1.0], Uniform, idx) 
    z_new_node_3 = ambient_forcing(rpg, op.vec, τ, Frand)
    @test isapprox(sum(g(z_new_node_3)), 0.0, atol = 1e-8)

    idx = idx_exclusive(rpg, ["u_r_2", "u_i_2", "θ_2", "ω_2"])
    dist_vec = [[0,1], [0, 2], [0, 2π] ./τ, [-5, 5] ./τ]
    Frand = Frand = random_force(rpg, dist_vec, Uniform, idx)
    z_new_node_2 = ambient_forcing(rpg, op.vec, τ, Frand)
    @test isapprox(sum(g(z_new_node_2)), 0.0, atol = 1e-8)
end

@testset "OrdinaryDiffEq_example" begin
    # adopting the Robertson Example from the DifferentialEquation docs
    # https://diffeq.sciml.ai/stable/tutorials/advanced_ode_example/#Handling-Mass-Matrices
    function rober(du,u,p,t)
        y₁,y₂,y₃ = u
        du[1] = -0.04 * y₁ + 1e4 * y₂ * y₃
        du[2] =  0.04 * y₁ - 1e4 * y₂ * y₃ - 3e7 * y₂^2
        du[3] =  y₁ + y₂ + y₃ - 1
    nothing
  end
  
    M = [1. 0  0
         0  1. 0
        0  0  0];

    ode_rober = ODEFunction(rober, mass_matrix = M) 
    u0 = [1.0,0.0,0.0]; # an inital condition which fulfills the constraint
  
    g_rober = constraint_equations(ode_rober)
    @test isapprox(sum(g_rober(u0)), 0.0, atol = 1e-8)

    # Randomly perturbing all varibales  
    Frand = random_force(ode_rober, [0.0,1], Uniform)
    z_new_all = ambient_forcing(ode_rober, u0, 2.0, Frand)
    @test isapprox(sum(g_rober(z_new_all)), 0.0, atol = 1e-8) 

    # only perturbing the second variable y₂
    h = [0, 1 ,0]
    z_new_2 = ambient_forcing(ode_rober, u0, 2.0, h)
    @test isapprox(sum(g_rober(z_new_2)), 0.0, atol = 1e-8) 
end