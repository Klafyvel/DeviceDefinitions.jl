module DeviceDefinitions

using MCUCommon: Access, Read, Write, ReadWrite, ReadWriteOnce, Unknown
using XML
using EnumX
using Mustache
using DocStringExtensions

const TEMPLATES_DIRECTORY = Ref{String}(joinpath(dirname(dirname(pathof(DeviceDefinitions))), "templates"))

import Pkg

include("structs.jl")
include("parsing.jl")
include("views.jl")
include("generate.jl")
include("deprecate.jl")

end # module DeviceDefinitions
