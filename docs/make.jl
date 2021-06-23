using Documenter
using Literate
using AmbientForcing
using NetworkDynamics
using PowerDynamics
using Distributions
using LightGraphs


# generate examples
examples = [
    joinpath(@__DIR__, "..", "examples", "DifferentialEquation_example.jl"),
    joinpath(@__DIR__, "..", "examples", "NetworkDynamics_example.jl"),
    joinpath(@__DIR__, "..", "examples", "PowerDynamics_example.jl"),
]

OUTPUT = joinpath(@__DIR__, "src/generated")
isdir(OUTPUT) && rm(OUTPUT, recursive=true)
mkpath(OUTPUT)

for ex in examples
    Literate.markdown(ex, OUTPUT)
    Literate.script(ex, OUTPUT)
end

makedocs(;
    modules=[AmbientForcing],
    authors="Anna Büttner and contributors",
    repo="https://github.com/Anbue63/AmbientForcing.jl",
    sitename="AmbientForcing.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://github.com/Anbue63/AmbientForcing.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
        "Examples" => ["DiffEq" => "generated/DifferentialEquation_example.md",
                       "NetworkDynamics" => "generated/NetworkDynamics_example.md",
                       "PowerDynamics" => "generated/PowerDynamics_example.md"]
    ],
)

deploydocs(;
    repo="github.com/Anbue63/AmbientForcing.jl",
    devbranch="master",
    # push_preview=true,
)