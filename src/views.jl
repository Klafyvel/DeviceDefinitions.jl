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

function view(element::T, path::AbstractString="", args...) where T 
    modulepath = joinpath(path, lowercase(string(element.name)) * ".jl")
    open(modulepath, "w") do io 
        view(io, element, args...)
    end
    return modulepath
end

include("views/register.jl")
include("views/cluster.jl")
include("views/peripheral.jl")
include("views/device.jl")
