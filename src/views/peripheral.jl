"Path to the mustache template for peripherals."
const PERIPHERAL_TEMPLATE_PATH = Ref{String}(joinpath(TEMPLATES_DIRECTORY[], "peripheral.tpl"))

"Mustache template for peripherals."
const PERIPHERAL_TEMPLATE = Ref{Mustache.MustacheTokens}(Mustache.load(PERIPHERAL_TEMPLATE_PATH[]))

struct PeripheralDefinitionContext
    name::String
    description::String
    baseaddress::String
end

function view(io::IO, peripheral::Peripheral)
    context = PeripheralDefinitionContext(
        peripheral.name,
        getoptionstring(peripheral, :description),
        "0x" * uppercase(string(peripheral.baseAddress.value, base=16, pad=16))
    )
    PERIPHERAL_TEMPLATE[](io, context)
    header = "using ..$(peripheral.name): baseAddress"
    prefix = something(peripheral.prependToName, "")
    postfix = something(peripheral.appendToName, "")
    for register in something(peripheral.registers, ())
        view(io, register, prefix, postfix, header)
    end
    for childcluster in something(peripheral.clusters, ())
        view(io, childcluster, prefix, postfix, header)
    end
    # The cluster template does not `end` the module to allow the use of the 
    # other views in the preceding for loops.
    println(io, "end # peripheral $(peripheral.name)\n")
    return nothing
end

