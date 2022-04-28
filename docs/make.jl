using Documenter, AmbientForcing

makedocs(;
    modules=[AmbientForcing],
    authors = "Anna Büttner, Michael Lindner and contributors",
    repo = "https://github.com/PIK-ICoNe/AmbientForcing.jl",
    sitename = "AmbientForcing.jl",
    pages = [
        "Ambient Forcing Docs" => "index.md",
        "Examples" => [
            "DifferentialEquations.jl Example" => "diffeq.md",
            "NetworkDynamics.jl Example" => "network_dynamics.md",
            "PowerDynamics.jl Example" => "power_dynamics.md"
    ]
])

deploydocs(repo = "github.com/PIK-ICoNe/AmbientForcing.jl.git")