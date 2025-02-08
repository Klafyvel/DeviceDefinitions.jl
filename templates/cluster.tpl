{{!/* vim: set filetype=mustache: */}}
{{!
Definition of a register. It expects a context type `ClusterDefinitionContext`. See src/views.jl.
}}
"""
    {{ name }}

{{ description }}
"""
module {{ name }}

{{ header }} as parentBaseAddress

const baseAddress = parentBaseAddress + {{ addressoffset }}

{{! We explicitely don't finish the module here, as we need to include the registers and clusters children }}
