"""
    generate(name, url, filename; parentdir=pwd(), kwargs...)
    generate(name, path; parentdir=pwd(), kwargs...)
    generate(existingpath)

Generate a Julia project from a SVD file. The project name will be set to `name` 
and located under `parentdir`. The SVD file can be either a `path` on your 
computer, or an `url` to a tarball that contains the SVD file in `filename`. In 
the latter case, the SVD file will be embedded in the generated project as an 
artifact, making the project lighter for your users.

It is also possible to re-generate an existing project either if the generated 
project path already exists, or even by only specifying `existingpath`. In this
latter case, the SVD file is retrieved from the previously generated project.

DeviceDefinitions.jl relies on PkgTemplates.jl for package generation (it comes 
in the form of a plugin for PkgTemplates.jl). Calling `generate` will actually 
create a template with the plugins listed in [`DEFAULT_PLUGINS`](@ref). `kwargs`
will be passed to the template.

See also [`DeviceDefinition`](@ref).
"""
function generate end

function cleanuppreviousgeneration(dir)
    @warn "Cleaning up previous generation in $dir. Make sure to bump version number after this operation."
    @info "Removing existing src/peripherals directory"
    srcpath = joinpath(dir, "src")
    rm(joinpath(srcpath, "peripherals.jl"); force=true)
    rm(joinpath(srcpath, "peripherals"); recursive=true, force=true)
    mkpath(srcpath)
    # to make sure the precompilation works
    open(joinpath(srcpath, "peripherals.jl"), "w") do io
        println(io,
                """
                module Peripherals

                end # module
                """)
    end
    return nothing
end

function generate(name::String, url::String, filename::String; parentdir::String=pwd(), kwargs...)
    template = PkgTemplates.Template(;
        dir = parentdir,
        plugins = [DEFAULT_PLUGINS..., DeviceDefinition(filename, url)],
        kwargs...
    )
    return template(name)
end
function generate(name::String, svdpath::String; parentdir::String=pwd(), kwargs...) 
    template = PkgTemplates.Template(;
        dir = parentdir,
        plugins = [DEFAULT_PLUGINS..., DeviceDefinition(svdpath, nothing)],
        kwargs...
    )
    return template(name)
end
function generate(projectpath)
    correctprojectpath = endswith(projectpath, "/") ? projectpath[begin:end-1] : projectpath
    if !isdir(correctprojectpath)
        template = PkgTemplates.Template(
            dir = correctprojectpath,
            plugins = [DEFAULT_PLUGINS..., DeviceDefinition(nothing, nothing)],
            interactive=true
        )
        return template(name)
    end
    modulename = PkgTemplates.pkg_name(correctprojectpath)
    cleanuppreviousgeneration(correctprojectpath)
    # Handle the svd file.
    view(ExistingSVD(), correctprojectpath)
    device = getdevice(ExistingSVD(), correctprojectpath, modulename)
    srcpath = joinpath(correctprojectpath, "src")
    return view(device, srcpath)
end
