"Path to the mustache template for devices."
const DEVICE_TEMPLATE_PATH = Ref{String}(joinpath(TEMPLATES_DIRECTORY[], "device.tpl"))

"Mustache template for devices."
const DEVICE_TEMPLATE = Ref{Mustache.MustacheTokens}(Mustache.load(DEVICE_TEMPLATE_PATH[]))

struct DeviceDefinitionContext
end

function view(device::Device, dir::String) 
    isfile(dir) && throw(ArgumentError("Directory `$dir` already exists!"))
    mkpath(dir)
    path = joinpath(dir, "peripherals.jl")
    return open(path, "w") do io
        view(io, device, dir)
    end
end

function view(io::IO, device::Device, basedir="")
    context = DeviceDefinitionContext()
    DEVICE_TEMPLATE[](io, context)
    childrenpath = joinpath(basedir, "peripherals")
    mkpath(childrenpath)
    for peripheral in device.peripherals
        peripheralpath = view(peripheral, childrenpath)
        peripheralpath = joinpath("peripherals", basename(peripheralpath))
        println(io, """include("$peripheralpath")\n""")
    end
    # The device template does not `end` the module to allow the use of the 
    # other views in the preceding for loops.
    println(io, "end # module Peripherals\n")
    return nothing
end

