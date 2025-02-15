"Path to the mustache template for registers."
const REGISTER_TEMPLATE_PATH = Ref{String}(joinpath(TEMPLATES_DIRECTORY[], "register.tpl"))

"Mustache template for registers."
const REGISTER_TEMPLATE = Ref{Mustache.MustacheTokens}(Mustache.load(REGISTER_TEMPLATE_PATH[]))

struct RegisterDefinitionContext
    name::String
    prefix::String
    postfix::String
    description::String
    header::String
    addressoffset::UInt
    fieldranges::Vector{Dict{String, Any}}
    fielddescriptions::Vector{Dict{String, String}} 
end

function view(io::IO, register::Register, prefix::AbstractString, postfix::AbstractString, header)
    fields = something(register.fields,())
    fieldranges = Dict{String, Any}[]
    fielddescriptions = Array{Dict{String, String}, 1}(undef, length(fields))

    lastoffset = lastwidth = 0
    for (i,field) in enumerate(fields)
        fielddescriptions[i] = Dict(["name"=>field.name, "description"=>getoptionstring(field, :name)])
        if lastoffset + lastwidth < first(field.bitRange)
            push!(fieldranges, Dict([
                "name"=>"_", 
                "length"=>first(field.bitRange) - (lastoffset+lastwidth), 
                "access"=>nothing
            ]))
        end
        isnothing(field.access) && throw(ArgumentError("Field `$(field.name)` in register `$(register.name)` doesn't have an access modifier!"))
        push!(fieldranges, Dict([
            "name"=>field.name, 
            "length"=>length(field.bitRange), 
            "access"=>something(field.access, ReadWrite)
        ]))
        lastoffset = first(field.bitRange)
        lastwidth = length(field.bitRange)
    end
    registersize = something(register.rpg.size, (;value=0)).value
    if isempty(fields)
        # Special case: mark the whole register as readable "field".
        lastwidth = registersize
        push!(fieldranges, Dict(["name"=>"_", "length"=>registersize, "access"=>nothing]))
    end
    if lastoffset + lastwidth < registersize
        push!(fieldranges, Dict(["name"=>"_", "length"=>registersize - (lastoffset + lastwidth), "access"=>nothing]))
    end
    context = RegisterDefinitionContext(
        register.name,
        prefix,
        postfix,
        escapedescription(getoptionstring(register, :description)),
        header,
        register.addressOffset,
        fieldranges,
        fielddescriptions,
    )
    REGISTER_TEMPLATE[](io, context)
    return nothing
end

