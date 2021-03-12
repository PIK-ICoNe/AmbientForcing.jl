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
    random_force(f::ODEFunction, dist_args, dist::UnionAll, idx_vec::Array{Array{Float64}})

Perturbes only the variables in given in idx_vec. Each variable is initalized using its own distribution.
"""
function random_force(f::ODEFunction, dist_args::Array{Array{Float64, 1}, 1}, 
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
    random_force(f::ODEFunction, dist_args::Array{Float64}, dist::UnionAll, idx_vec)

Perturbes only the variables in given in idx_vec.
"""
function random_force(f::ODEFunction, dist_args::Array{Float64}, 
                    dist::UnionAll, idx_vec)
    M = f.mass_matrix
    len_M = size(M, 1)
    Frand = zeros(len_M)

    Frand[idx_vec] = rand(dist(dist_args...), length(idx_vec))
    return Frand
end


"""
    random_force(f::ODEFunction, dist_args, dist::UnionAll)
Perturbes all variables.
"""
function random_force(f::ODEFunction, dist_args::Array{Float64}, dist::UnionAll)
    M = f.mass_matrix
    len_M = size(M, 1)
    Frand = rand(dist(dist_args...), len_M)
end