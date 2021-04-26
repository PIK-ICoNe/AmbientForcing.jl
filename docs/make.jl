using Documenter, AmbientForcing
using Literate


# generate examples
examples = [
    joinpath(@__DIR__, "..", "examples", "DifferentialEquation_example.jl"),
    # joinpath(@__DIR__, "..", "examples", "kuramoto_network.jl"),
    #joinpath(@__DIR__, "..", "examples", "kuramoto_without_nd.jl"),
    #joinpath(@__DIR__, "..", "examples", "pd_node.jl"),
]

OUTPUT = joinpath(@__DIR__, "src/generated")
isdir(OUTPUT) && rm(OUTPUT, recursive=true)
mkpath(OUTPUT)

for ex in examples
    Literate.markdown(ex, OUTPUT)
    Literate.script(ex, OUTPUT)
end

makedocs(;
    modules = [AmbientForcing],
    authors = "Anna Büttner and contributors",
    sitename = "AmbientForcing.jl",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://github.com/Anbue63/AmbientForcing.jl",
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "Examples" => ["OrdinaryDiffEq" => "generated/DifferentialEquation_example.md",
                       #"PowerDynamics.jl Node" => "generated/pd_node.md",
                       # "Kuramoto Network" => "generated/kuramoto_network.md",
                       #"Kuramoto without ND.jl" => "generated/kuramoto_without_nd.md"
                    ]
    ],
)


deploydocs(;
    repo="https://github.com/Anbue63/AmbientForcing.jl",
    devbranch="master",
    # push_preview=true,
)