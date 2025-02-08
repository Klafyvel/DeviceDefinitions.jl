@kwdef mutable struct Register
    derivedFrom::Option{String} = nothing
    parent::Option{Register} = nothing
    deg::DimElementGroup
    name::String
    displayName::Option{String} = nothing
    description::Option{String} = nothing
    alternateGroup::Option{String} = nothing
    alternateRegister::Option{Identifier} = nothing
    addressOffset::SNNI
    rpg::RegisterPropertiesGroup
    dataType::Option{DataType} = nothing
    modifiedWriteValues::ModifiedWriteValue.T = ModifiedWriteValue.Modify
    writeConstraint::Option{WriteConstraint} = nothing
    readAction::ReadAction.T
    fields::Vector{Field} = Field[]
end
Base.copy(p::Register) = Register(;(n => getfield(p, n) for n in fieldnames(Register))...)

function Base.show(io::IO, m::MIME"text/plain", r::Register)
    base_indent = get(io, :indent, "")
    indent = base_indent * "  "
    println(io, base_indent, "Register: ", r.name)
    println(io, indent, "description: ", @something r.description Some(nothing))
    println(io, indent, "derivedFrom: ", @something r.derivedFrom Some(nothing))
    println(io, indent, "alternateGroup: ", @something r.alternateGroup Some(nothing))
    println(io, indent, "alternateRegister: ", @something r.alternateRegister Some(nothing))
    println(io, indent, "addressOffset: ", r.addressOffset)
    println(io, indent, "modifiedWriteValues: ", r.modifiedWriteValues)
    println(io, indent, "readAction: ", r.readAction)
    get(io, :compact, false) && return
    for f in r.fields
        show(IOContext(io, :indent => indent), m, f)
    end
end

