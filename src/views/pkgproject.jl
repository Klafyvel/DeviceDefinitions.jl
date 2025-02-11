import Pkg

struct PkgProject end

function view(project::PkgProject, dir::String) 
    current_project = Base.active_project()
    Pkg.activate(dir)
    Pkg.add("MCUCommon")
    Pkg.add("Pkg")
    Pkg.add("LazyArtifacts")
    Pkg.compat("julia", "1.6")
    Pkg.compat("MCUCommon", "0.1.5")
    Pkg.compat("Pkg", "1")
    Pkg.compat("LazyArtifacts", "1")
    open(joinpath(dir, ".gitignore"), "w") do io
        println(io, "Manifest.toml")
    end
    Pkg.activate(current_project)
    return nothing
end
