using Documenter
using AmbientForcing

makedocs(
    sitename = "AmbientForcing",
    format = Documenter.HTML(),
    modules = [AmbientForcing]
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
