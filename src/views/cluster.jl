"Path to the mustache template for clusters."
const CLUSTER_TEMPLATE_PATH = Ref{String}(joinpath(TEMPLATES_DIRECTORY[], "cluster.tpl"))

"Mustache template for clusters."
const CLUSTER_TEMPLATE = Ref{Mustache.MustacheTokens}(Mustache.load(CLUSTER_TEMPLATE_PATH[]))

struct ClusterDefinitionContext
    name::String
    description::String
    header::String
    addressoffset::UInt
end

function view(io::IO, cluster::Cluster, prefix::AbstractString, postfix::AbstractString, header)
    context = ClusterDefinitionContext(
        cluster.name,
        getoptionstring(cluster, :description),
        header,
        cluster.addressOffset
    )
    CLUSTER_TEMPLATE[](io, context)
    childrenheader = "using ..$(cluster.name): baseAddress"
    for register in something(cluster.registers, ())
        view(io, register, prefix, postfix, childrenheader)
    end
    childrenheader = "using ..$(cluster.name): parentBaseAddress"
    for childcluster in something(cluster.clusters, ())
        view(io, childcluster, prefix, postfix, childrenheader)
    end
    # The cluster template does not `end` the module to allow the use of the 
    # other views in the preceding for loops.
    println(io, "end # cluster $(cluster.name)\n")
    return nothing
end

