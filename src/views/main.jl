"Path to the mustache template for main file."
const MAIN_TEMPLATE_PATH = Ref{String}(joinpath(TEMPLATES_DIRECTORY[], "main.tpl"))

"Mustache template for devices."
const MAIN_TEMPLATE = Ref{Mustache.MustacheTokens}(Mustache.load(MAIN_TEMPLATE_PATH[]))
struct DeviceProject 
    device::Device
    name::String
    svdstrategy
end

struct DeviceProjectDefinitionContext 
    name::String
    license::String
    svdfunction::String
end

function view(project::DeviceProject, dir::String) 
    mainmodulepath = joinpath(dir, project.name * ".jl")
    return open(mainmodulepath, "w") do io
        view(io, project, dir)
    end
end

function svdpathtemplate(project::DeviceProject, l::LocalSVD)
    return "svdpath() = joinpath(dirname(dirname(pathof($(project.name)))), \"src\", \"SVD\", \"$(basename(l.svdpath))\")"
end

function svdpathtemplate(::DeviceProject, a::ArtifactSVD)
    return "svdpath() = joinpath(artifact\"svdsource\", \"$(a.filename)\")"
end

function view(io::IO, project::DeviceProject, basedir)
    context = DeviceProjectDefinitionContext(
        project.name, 
        getoptionstring(project.device, :licenseText),
        svdpathtemplate(project, project.svdstrategy)
    )
    MAIN_TEMPLATE[](io, context)
    return view(project.device, basedir)
end

