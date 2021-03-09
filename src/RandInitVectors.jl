function RandomForce(f::ODEFunction, dist_args, 
    dist::UnionAll, node::Int64, tau; method = "Voltage")
    M = f.mass_matrix
    len_M = size(M, 1)
    Frand = zeros(len_M)
    if method == "Voltage" # Perturbs only the voltage at a node
        node_vars = NodeToVarIdxVolt(f, node)
        Frand[node_vars] = rand(dist(dist_args...), length(node_vars))
    elseif  method == "All" # Perturbs all variables at a node
        node_vars = NodeToVarIdx(f, node)
        Frand[node_vars[1:2]] = rand(dist(dist_args...), 2) # Perturbes the voltages
        if length(node_vars) > 2
            Frand[node_vars[3]] = rand(dist(0, 2π/tau)) # Perturbes the angle θ
            Frand[node_vars[4]] = rand(dist(-100/tau, 100/tau)) # Perturbes the angular velocity ω
        end
    end
    return Frand
end

function RandomForce(dist_args, dist::UnionAll, len_M::Int64)
Frand = rand(dist(dist_args...), len_M)
end

"""
Takes a ODEFunction from PowerDynamics and returns the indexes of the dynamical
variables associated to a node.
Inputs:
f: The rigthhand side of a PowerGrid object
node: Variable indexes of this node are found
Outputs:
vars_array: Array of the indexes of the variables of the node
"""
function NodeToVarIdx(f::ODEFunction, node::Int64)
    M = f.mass_matrix
    len_M = size(M, 1)
    var_array = []

    for i in 1:len_M
        str = string(f.syms[i])
        idx = findlast('_', str)
        node_num = parse(Int64, str[idx + 1:end])

        if node_num > node
            return var_array
        end

        if node_num == node
            append!(var_array, i)
        end
    end
    return var_array
end

"""
Takes a ODEFunction from PowerDynamics and returns the indexes of the voltages
associated to a node.
Inputs:
f: The rigthhand side of a PowerGrid object
node: Variable indexes of this node are found
Outputs:
vars_array: Array of the indexes of the voltages of the node
"""
function NodeToVarIdxVolt(f::ODEFunction, node::Int64)
    M = f.mass_matrix
    len_M = size(M, 1)
    var_array = []

    ur = "u_r" * "_" * string(node)
    ui = "u_i" * "_" * string(node)

    for i in 1:len_M
        if string(f.syms[i]) == ui
            append!(var_array, i)
        elseif string(f.syms[i]) == ur
        append!(var_array, i)
        end
    end
    return var_array
end