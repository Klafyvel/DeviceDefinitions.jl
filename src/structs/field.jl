@enumx ModifiedWriteValue OneToClear OneToSet OneToToggle ZeroToClear ZeroToSet ZeroToToggle Clear Set Modify
function ModifiedWriteValue.T(s::AbstractString)
    if s == "oneToClear"
        ModifiedWriteValue.OneToClear
    elseif s == "oneToSet"
        ModifiedWriteValue.OneToSet
    elseif s == "oneToToggle"
        ModifiedWriteValue.OneToToggle
    elseif s == "zeroToClear"
        ModifiedWriteValue.ZeroToClear
    elseif s == "zeroToSet"
        ModifiedWriteValue.ZeroToSet
    elseif s == "zeroToToggle"
        ModifiedWriteValue.ZeroToToggle
    elseif s == "clear"
        ModifiedWriteValue.Clear
    elseif s == "set"
        ModifiedWriteValue.Set
    elseif s == "modify"
        ModifiedWriteValue.Modify
    else
        @warn "Unknown ModifiedWriteValue:" Value = s
    end
end

@enumx ReadAction Clear Set Modify ModifyExternal NotModified
function ReadAction.T(s::AbstractString)
    if s == "clear"
        ReadAction.Clear
    elseif s == "set"
        ReadAction.Set
    elseif s == "modify"
        ReadAction.Modify
    elseif s == "modifyExternal"
        ReadAction.ModifyExternal
    elseif s == "notModified"
        ReadAction.NotModified
    else
        @warn "Unknown ReadAction:" Value = s
    end
end

struct BitRange
    extent::UnitRange{Int}
    function BitRange(; kwargs...)
        k = keys(kwargs)
        if :bitOffset in k && :bitWidth in k
            start = parse(Int, kwargs[:bitOffset])
            stop = start + parse(Int, kwargs[:bitWidth]) - 1
            return new(start:stop)
        elseif :lsb in k && :msb in k
            lsb = parse(Int, kwargs[:lsb])
            msb = parse(Int, kwargs[:msb])
            return new(lsb:msb)
        elseif :bitRange in k
            m = match(r"^\[(?<msb>\d+):(?<lsb>\d+)\]$", kwargs[:bitRange])
            lsb = parse(Int, m[:lsb])
            msb = parse(Int, m[:msb])
            return new(lsb:msb)
        end

        throw(ArgumentError("Invalid Bitrange keys given!"))
    end
end
Base.first(br::BitRange) = first(br.extent)
Base.last(br::BitRange) = last(br.extent)
Base.length(br::BitRange) = length(br.extent)
Base.iterate(br::BitRange) = iterate(br.extent)
Base.iterate(br::BitRange, state) = iterate(br.extent, state)

@kwdef mutable struct Field
    derivedFrom::Option{String} = nothing
    parent::Option{Field} = nothing
    deg::DimElementGroup
    name::DimableIdentifier
    description::Option{String} = nothing
    bitRange::BitRange
    access::Option{Access} = nothing
    modifiedWriteValues::ModifiedWriteValue.T = ModifiedWriteValue.Modify
    writeConstraint::Option{WriteConstraint} = nothing
    readAction::ReadAction.T
    enumeratedValues::Vector{EnumeratedValue} = EnumeratedValue[]
end
Base.copy(p::Field) = Field(;(n => getfield(p, n) for n in fieldnames(Field))...)

function Base.show(io::IO, ::MIME"text/plain", f::Field)
    base_indent = get(io, :indent, "")
    indent = base_indent * "  "
    println(io, base_indent, "Field: ",                     f.name.value                   )
    println(io, indent, "description: ",         @something f.description     Some(nothing))
    println(io, indent, "derivedFrom: ",         @something f.derivedFrom     Some(nothing))
    println(io, indent, "bitRange: ",            @something f.bitRange        Some(nothing))
    println(io, indent, "access: ",              @something f.access          Some(nothing))
    println(io, indent, "modifiedWriteValues: ",            f.modifiedWriteValues          )
    println(io, indent, "writeConstraint: ",     @something f.writeConstraint Some(nothing))
    println(io, indent, "readAction: ",                     f.readAction                   )
end

