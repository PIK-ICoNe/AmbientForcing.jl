"""
    idx_exclusive(f::ODEFunction, str::Array{String})
"""
function idx_exclusive(f::ODEFunction, str::Array{String})
    idx_vec = Array{Int64}(undef, length(str))
   
    for j in 1:length(str)
        for (i, s) in enumerate(f.syms)
            if string(str[j]) == string(s)
                idx_vec[j] = i
            end
        end
    end
    return idx_vec
end

"""
    RandomForce(f::ODEFunction, dist_args, dist::UnionAll, idx_vec::Array{Array{Float64}})

Perturbes only the variables in given in idx_vec. Each variable is initalized using its own distribution.
"""
function RandomForce(f::ODEFunction, dist_args::Array{Array{Float64, 1}, 1}, 
                    dist::UnionAll, idx_vec)
    if length(idx_vec) != length(dist_args)
        error("Please give dist_args for each var you want to perturb.")
    end
    M = f.mass_matrix
    len_M = size(M, 1)
    Frand = zeros(len_M)
    for i in 1:length(idx_vec)
        Frand[idx_vec[i]] = rand(dist(dist_args[i]...))
    end
    return Frand
end

"""
    RandomForce(f::ODEFunction, dist_args::Array{Float64}, dist::UnionAll, idx_vec)

Perturbes only the variables in given in idx_vec.
"""
function RandomForce(f::ODEFunction, dist_args::Array{Float64}, 
                    dist::UnionAll, idx_vec)
    M = f.mass_matrix
    len_M = size(M, 1)
    Frand = zeros(len_M)

    Frand[idx_vec] = rand(dist(dist_args...), length(idx_vec))
    return Frand
end


"""
    RandomForce(f::ODEFunction, dist_args, dist::UnionAll)
Perturbes all variables.
"""
function RandomForce(f::ODEFunction, dist_args::Array{Float64}, dist::UnionAll)
    M = f.mass_matrix
    len_M = size(M, 1)
    Frand = rand(dist(dist_args...), len_M)
end

function voltage_str(node::Int)
    voltage_str = ["u_r_" * string(node), "u_i_" * string(node)]
end

function full_str(pg::PowerGrid, node::Int)
    if length(symbolsof(pg.nodes[node])) == 2
        full_str = ["u_r_" * string(node), "u_i_" * string(node)]
    elseif :θ ∈ symbolsof(pg.nodes[node])
        if :ω ∈ symbolsof(pg.nodes[node])
            full_str = ["u_r_" * string(node), "u_i_" * string(node), "θ_" * string(node), "ω_" * string(node)]
        else
            error("Please constrcut the vector manually")
        end
    else
        error("Please constrcut the vector manually")
    end
end

function pd_node_idx(pg::PowerGrid, node::Int, method::String)
    if method == "Voltage"
        str_vec = voltage_str(node)
    elseif method == "All"
        str_vec = full_str(pg, node)
    else
        error("Please use a valid method.")
    end
    idx_vec =  idx_exclusive(rhs(pg), str_vec)
end