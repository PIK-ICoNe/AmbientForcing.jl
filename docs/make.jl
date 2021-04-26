using Documenter, AmbientForcing
using Literate

# generate examples
my_path = joinpath(@__DIR__, "..", "examples")

OUTPUT = joinpath(@__DIR__, "src/generated")
isdir(OUTPUT) && rm(OUTPUT, recursive=true)
mkpath(OUTPUT)

Literate.markdown(joinpath(my_path, "DifferentialEquation_example.jl"), OUTPUT)
Literate.script(joinpath(my_path, "DifferentialEquation_example.jl"), OUTPUT)

#Literate.markdown(joinpath(path, "NetworkDynamics_example.jl"), OUTPUT)
#Literate.markdown(joinpath(path, "PowerDynamics_example.jl"), OUTPUT)

makedocs(sitename = "AmbientForcing.jl",
        modules = [AmbientForcing],
        authors = "Anna Büttner and contributors",
        format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
        pages = [
        "Home" => "index.md",
        "Examples" => ["OrdinaryDiffEq" => "generated/DifferentialEquation_example.md",
                       #"PowerDynamics" => "generated/PowerDynamics_example.md",
                       #"NetworkDynamics" => "generated/NetworkDynamics_example.md"
                       ]
    ],
)

deploydocs(;
    repo = "github.com/Anbue63/AmbientForcing.jl",
    devbranch = "master",
)