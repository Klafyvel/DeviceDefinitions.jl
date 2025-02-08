"Path to the mustache template for main file."
const MAIN_TEMPLATE_PATH = Ref{String}(joinpath(TEMPLATES_DIRECTORY[], "main.tpl"))

"Mustache template for devices."
const MAIN_TEMPLATE = Ref{Mustache.MustacheTokens}(Mustache.load(MAIN_TEMPLATE_PATH[]))
struct DeviceProject 
    device::Device
    name::String
end

struct DeviceProjectDefinitionContext 
    name::String
    license::String
end

function view(project::DeviceProjectFile, dir::String) 
    mainmodulepath = joinpath(dir, project.name * ".jl")
    return open(mainmodulepath, "w") do io
        view(io, project, dir)
    end
end

function view(io::IO, project::DeviceProjectFile, basedir)
    context = DeviceProjectDefinitionContext(project.name, getstringoption(project.device, "No license text found!"))
    MAIN_TEMPLATE[](io, context)
    return view(project.device, basedir)
end

