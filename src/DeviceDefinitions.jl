module DeviceDefinitions

using MCUCommon: Access, Read, Write, ReadWrite, ReadWriteOnce, Unknown
using XML
using EnumX
using Mustache
using DocStringExtensions
import Pkg
using PkgTemplates: PkgTemplates, @plugin, @with_kw_noshow, Plugin

const TEMPLATES_DIRECTORY = Ref{String}(joinpath(dirname(dirname(pathof(DeviceDefinitions))), "templates"))

include("structs.jl")
include("parsing.jl")
include("views.jl")
include("svdstrategies.jl")
include("pkgtemplates.jl")
include("generate.jl")
include("deprecate.jl")

end # module DeviceDefinitions
