"""
    generate(name, url, filename; parentdir=pwd())
    generate(name, path; parentdir=pwd())
    generate(existingpath)

Generate a Julia project from a SVD file. The project name will be set to `name` 
and located under `parentdir`. The SVD file can be either a `path` on your 
computer, or an `url` to a tarball that contains the SVD file in `filename`. In 
the latter case, the SVD file will be embedded in the generated project as an 
artifact, making the project lighter for your users.

It is also possible to re-generate an existing project either if the generated 
project path already exists, or even by only specifying `existingpath`. In this
latter case, the SVD file is retrieved from the previously generated project.
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

function getdevice(strategy::LocalSVD, _, _)
    return readSVD(strategy.svdpath)
end

function getdevice(::ExistingSVD, projectdir, modulename)
    julia = joinpath(Sys.BINDIR, Base.julia_exename())
    cmd = `$julia -e "import $modulename; println($modulename.svdpath())"`
    io = IOBuffer()
    withenv("JULIA_PROJECT"=>projectdir) do 
        run(pipeline(cmd, stdout=io))
    end
    path = chomp(String(take!(io)))
    return readSVD(path)
end

function getdevice(strategy::ArtifactSVD, _, _)
    return readSVD(strategy.downloadedsvdpath)
end

generate(name::String, url::String, filename::String; parentdir::String=pwd()) = generate(ArtifactSVD(url, filename, nothing, nothing, nothing), name, parentdir)
generate(name::String, svdpath::String; parentdir::String=pwd()) = generate(LocalSVD(svdpath), name, parentdir)
function generate(projectpath)
    correctprojectpath = endswith(projectpath, "/") ? projectpath[begin:end-1] : projectpath
    return generate(ExistingSVD(), basename(correctprojectpath), dirname(correctprojectpath))
end

function generate(svdstrategy, name::String, parentdir::String=pwd())
    hassuffix = endswith(name, ".jl")
    projectname = hassuffix ? name : name*".jl"
    modulename = hassuffix ? name[begin:end-3] : name
    projectdir = joinpath(parentdir, projectname)
    projectexists = isdir(projectdir)
    srcpath = joinpath(projectdir, "src")
    if projectexists
        cleanuppreviousgeneration(projectdir)
    else
        cd(parentdir) do
            Pkg.generate(projectname)
        end
    end
    # generate the project dir first, so there's no need to precompile all of the definitions
    if !projectexists
        view(PkgProject(), projectdir)
    end
    # Handle the svd file.
    view(svdstrategy, projectdir)
    device = getdevice(svdstrategy, projectdir, modulename)
    # only create the new module file if this is a new project
    if projectexists
        view(device, srcpath)
    else
        view(DeviceProject(device, modulename, svdstrategy), srcpath)
    end
    @info "Done"
end
