@kwdef mutable struct AddressBlock
    offset::SNNI
    size::SNNI
    usage::Usage.T
    protection::Option{ProtectionString} = nothing
end

@kwdef mutable struct Interrupt
    name::String
    description::Option{String} = nothing
    value::Int
end

@kwdef mutable struct Peripheral
    derivedFrom::Option{DimableIdentifier} = nothing
    parent::Option{Peripheral} = nothing
    deg::DimElementGroup = DimElementGroup(; dim=SNNI("0x0"), dimIncrement=SNNI("0x0"))
    name::DimableIdentifier
    version::Option{String} = nothing
    description::Option{String} = nothing
    alternatePeripheral::Option{DimableIdentifier} = nothing
    groupName::Option{String} = nothing
    prependToName::Option{Identifier} = nothing
    appendToName::Option{Identifier} = nothing
    headerStructName::Option{DimableIdentifier} = nothing
    disableCondition::Option{String} = nothing
    baseAddress::SNNI
    rpg::RegisterPropertiesGroup = RegisterPropertiesGroup()
    addressBlock::Option{Vector{AddressBlock}} = nothing
    interrupt::Option{Vector{Interrupt}} = nothing
    registers::Option{Vector{Register}} = nothing
    clusters::Option{Vector{Cluster}} = nothing
end

function Base.show(io::IO, m::MIME"text/plain", p::Peripheral)
    base_indent = get(io, :indent, "")
    indent = base_indent * "  "
    println(io, base_indent, "Peripheral: ", p.name)
    println(io, indent, "description: ", @something p.description Some(nothing))
    println(io, indent, "derivedFrom: ", @something p.derivedFrom Some(nothing))
    println(io, indent, "alternatePeripheral: ", @something p.alternatePeripheral Some(nothing))
    println(io, indent, "baseAddress: ", p.baseAddress)
    regs = @something p.registers Some(())
    for r in regs
        show(IOContext(io, :indent => indent, :compact => true), m, r)
    end
end
Base.copy(p::Peripheral) = Peripheral(;(n => getfield(p, n) for n in fieldnames(Peripheral))...)


