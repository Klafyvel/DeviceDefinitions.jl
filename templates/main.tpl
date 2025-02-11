{{!/* vim: set filetype=mustache: */}}
{{!
Expects a context type `DeviceProjectDefinitionContext`. See src/views.jl.
}}
module {{ name }}

# This project was generated from the SVD file whose path is returned by `svdpath()`.

#=
The following is the original license text of the SVD file.
Its license may not necessarily apply to this generated code.

{{{ license }}}

=#

using Pkg.Artifacts
using LazyArtifacts
"""
    svdpath()

Return the path to the SVD file used to generate the register mapping of this 
package, downloading it if required.
"""
{{{ svdfunction }}}

using MCUCommon: Register, Field

include("peripherals.jl")

end # module {{ name }}
