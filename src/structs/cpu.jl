struct CPUName
    value::String
    function CPUName(s::AbstractString)
        s ∉ cpunames && throw(ArgumentError("Unknown CPU name: `$s`"))
        new(s)
    end
end
const cpunames = ("CM0", "CM0PLUS", "CM0+", "CM1", "CM3", "CM4", "CM7", "CM23", "CM33", "CM35P", "CM55", "CM85", "SC000", "SC300", "ARMV8MML", "ARMV8MBL", "ARMV81MML", "CA5", "CA7", "CA8", "CA9", "CA15", "CA17", "CA53", "CA57", "CA72", "SMC1", "other")

struct Revision
    r::Int
    p::Int
    function Revision(s::AbstractString)
        m = match(r"^r([0-9]*)p([0-9]*)$", s)
        isnothing(m) && throw(ArgumentError("Invalid revision: `$s`"))
        return new(parse(Int, m[1]), parse(Int, m[2]))
    end
end

struct Endian
    value::String
    function Endian(s::AbstractString)
        s in endians || throw(ArgumentError("Invalid endianness: `$s`"))
        new(s)
    end
end
const endians = ("little", "big", "selectable", "other")

mutable struct SauRegionsConfig

end

@kwdef mutable struct CPU
    name::CPUName
    revision::Revision
    endian::Endian
    mpuPresent::Bool
    fpuPresent::Bool
    fpuDP::Option{Bool} = nothing
    dspPresent::Option{Bool} = nothing
    icachePrsent::Option{Bool} = nothing
    dcachePresent::Option{Bool} = nothing
    itcmPresent::Option{Bool} = nothing
    dtcmPresent::Option{Bool} = nothing
    vtorPresent::Option{Bool} = nothing
    nvicPrioBits::SNNI
    vendorSystickConfig::Bool
    deviceNumInterrupts::Option{ScaledNonNegativeInteger} = nothing
    sauNumRegions::Option{ScaledNonNegativeInteger} = nothing
    sauRegionsConfig::Option{SauRegionsConfig} = nothing
end


