{{!/* vim: set filetype=mustache: */}}
{{!
Definition of a register. It expects a context type `PeripheralDefinitionContext`. See src/views.jl.
}}
"""
    {{ name }}

{{ description }}
"""
module {{ name }}

const baseAddress = Ptr{UInt32}({{ baseaddress }})

{{! We explicitely don't finish the module here, as we need to include the registers and clusters children }}
