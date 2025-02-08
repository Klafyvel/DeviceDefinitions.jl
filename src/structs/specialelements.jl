const diRegex1 = r"^((?:%s)|(?:%s)[_A-Za-z]{1}[_A-Za-z0-9]*)$"
const diRegex2 = r"^([_A-Za-z]{1}[_A-Za-z0-9]*(?:\[%s\])?)$"
const diRegex3 = r"^([_A-Za-z]{1}[_A-Za-z0-9]*(?:%s)?[_A-Za-z0-9]*)$"
struct DimableIdentifier
    value::String
    function DimableIdentifier(s::AbstractString)
        m = @something match(diRegex1, s) match(diRegex2, s) match(diRegex3, s) Some(nothing)
        isnothing(m) && throw(ArgumentError("Not a dimable identifier: `$s`"))
        return new(only(m))
    end
end
Base.show(io::IO, di::DimableIdentifier) = print(io, di.value)
Base.convert(::Type{String}, di::DimableIdentifier) = di.value
Base.:(==)(di::DimableIdentifier, s::String) = di.value == s
Base.:(==)(s::String, di::DimableIdentifier) = di.value == s

struct ProtectionString
    value::String
    function ProtectionString(s::AbstractString)
        s in ("s", "n", "p") || throw(ArgumentError("Not a valid protection string: `$s`"))
        return new(s)
    end
end

const numRegex = r"^([0-9]+)\-([0-9]+)$"
const letterRegex = r"^([A-Z])-([A-Z])$"
const listRegex = r"^[_0-9a-zA-Z]+(?:,\s*[_0-9a-zA-Z]+)+$"
const singleListRegex = r"^[_0-9a-zA-Z]+$"
struct DimIndex
    indices::AbstractVector
    function DimIndex(s::AbstractString)
        numRange = match(numRegex, s)
        if !isnothing(numRange)
            lowStr, highStr = numRange
            low = parse(Int, lowStr)
            high = parse(Int, highStr)
            return new(low:high)
        end

        letterRange = match(letterRegex, s)
        if !isnothing(letterRange)
            lowStr, highStr = numRange
            low = only(lowStr)
            high = only(highStr)
            return new(low:high)
        end

        listRange = match(listRegex, s)
        if !isnothing(listRange)
            vals = map(only, eachmatch(singleListRegex, s))
            return new(vals)
        end

        throw(ArgumentError("Given string doesn't match any of the known patterns: `$s`"))
    end
end

const snniRegex = r"^[+]?(0x|0X|#)?([0-9a-fA-Fx]+)([kmgtKMGT]?)$"
struct ScaledNonNegativeInteger
    value::UInt
    scale::String
    function ScaledNonNegativeInteger(s::AbstractString)
        m = match(snniRegex, s)
        isnothing(m) && throw(ArgumentError("Invalid ScaledNonNegativeInteger string: `$s`"))
        if m[1] == "#"
            base = 2
            num  = replace(m[2], "x" => "0")
        elseif m[1] === nothing
            base = 10
            num  = m[2]
        else
            base = 16
            num = m[2]
        end
        new(parse(UInt, num; base), m[3])
    end
end
const SNNI = ScaledNonNegativeInteger
Base.show(io::IO, snni::SNNI) = show(io, snni.value)
Base.convert(::Type{UInt}, snni::SNNI) = snni.value

const itRegex = r"^([_A-Za-z0-9]*)$"
struct Identifier
    ident::String
    function Identifier(s::AbstractString)
        m = match(itRegex, s)
        isnothing(m) && throw(ArgumentError("Given string is not an identifier: `$s`"))
        return new(only(m))
    end
end
Base.string(id::Identifier) = id.ident

@kwdef mutable struct EnumeratedValue
    name::Identifier
    description::Option{String} = nothing
    value::SNNI
    isDefault::Bool
end

mutable struct DimArrayIndex
    headerEnumName::String
    values::Vector{EnumeratedValue}
end

@kwdef mutable struct DimElementGroup
    dim::SNNI
    dimIncrement::SNNI
    dimIndex::Option{DimIndex} = nothing
    dimName::Option{Identifier} = nothing
    dimArrayIndex::Option{DimArrayIndex} = nothing
end
Base.length(deg::DimElementGroup) = deg.dim.value
function Base.iterate(deg::DimElementGroup, state=0)
    state >= deg.dim.value && return nothing
    if !isnothing(deg.dimArrayIndex)
        deg.dimArrayIndex[state+1], state+1
    else
        state, state+1
    end
end

@kwdef mutable struct RegisterPropertiesGroup
    size::Option{ScaledNonNegativeInteger} = nothing
    access::Option{Access} = nothing
    protection::Option{ProtectionString} = nothing
    resetValue::Option{ScaledNonNegativeInteger} = nothing
    resetMask::Option{ScaledNonNegativeInteger} = nothing
end
