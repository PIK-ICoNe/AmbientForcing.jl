using Documenter
using Literate
using AmbientForcing
using NetworkDynamics, Distributions
using Graphs
using OrdinaryDiffEq

# generate examples
examples = [joinpath(@__DIR__, "..", "examples", "NetworkDynamics_example.jl")]

OUTPUT = joinpath(@__DIR__, "src/generated")
isdir(OUTPUT) && rm(OUTPUT, recursive=true)
mkpath(OUTPUT)

for ex in examples
    println(OUTPUT)
    Literate.markdown(ex, OUTPUT)
    Literate.script(ex, OUTPUT)
end

makedocs(;
    modules=[AmbientForcing],
    authors = "Anna Büttner, Michael Lindner and contributors",
    repo = "https://github.com/PIK-ICoNe/AmbientForcing.jl",
    sitename = "AmbientForcing.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "false",
        canonical = "https://github.com/PIK-ICoNe/AmbientForcing.jl",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "Network Dynamics Example" => "NetworkDynamics_example.md"
    ],
)

deploydocs(
    repo = "github.com/PIK-ICoNe/AmbientForcing.jl.git",
    devbranch="symjac",
)