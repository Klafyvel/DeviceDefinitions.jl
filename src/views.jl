function getoptionstring(element::T, field) where T 
    return something(
        getfield(element, field),
        "No $field of $(lowercase(string(T)))!"
    )
end

"""
    $(TYPEDSIGNATURES)

Generate a module definition for the given element.
"""
function view end

function view(element, path::AbstractString="", args...)
    modulepath = joinpath(path, lowercase(string(element.name)) * ".jl")
    open(modulepath, "w") do io 
        view(io, element, args...)
    end
    return modulepath
end

include("views/artifacts.jl")
include("views/register.jl")
include("views/cluster.jl")
include("views/peripheral.jl")
include("views/device.jl")
include("views/pkgproject.jl")
include("views/existingsvd.jl")
include("views/localsvd.jl")
include("views/main.jl")
