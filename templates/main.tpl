{{!/* vim: set filetype=mustache: */}}
{{!
Expects a context type `DeviceProjectDefinitionContext`. See src/views.jl.
}}
module {{ name }}

# This project was generated from the SVD file found under `src/SVD`.

#=
The following is the original license text of the SVD file.
Its license may not necessarily apply to this generated code.

{{ license }}

=#

using MCUCommon: Register, Field

include("peripherals.jl")

end # module {{ name }}
