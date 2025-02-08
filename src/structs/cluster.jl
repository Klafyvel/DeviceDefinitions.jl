@kwdef mutable struct Cluster
    derivedFrom::Option{String} = nothing
    parent::Option{Cluster} = nothing
    deg::DimElementGroup
    name::DimableIdentifier
    description::Option{String} = nothing
    alternateCluster::Option{DimableIdentifier} = nothing
    headerStructName::Option{Identifier} = nothing
    addressOffset::SNNI
    rpg::RegisterPropertiesGroup = RegisterPropertiesGroup()
    registers::Option{Vector{Register}} = nothing
    clusters::Option{Vector{Cluster}} = nothing
end
Base.copy(p::Cluster) = Cluster(;(n => getfield(p, n) for n in fieldnames(Cluster))...)

@enumx Usage Registers Buffer Reserved
function Usage.T(s::String)
    if s == "registers"
        Usage.Registers
    elseif s == "buffer"
        Usage.Buffer
    elseif s == "reserved"
        Usage.Reserved
    else
        @error "Unknown usage:" Usage = s
    end
end

