{{!/* vim: set filetype=mustache: */}}
{{!
Definition of a register. It expects a context type `RegisterDefinitionContext`. See src/views.jl.
}}
"""
    {{ name }}

{{ description }}
"""
module {{ name }}Mod

using MCUCommon: @regdef, Read, Write, ReadWrite, ReadWriteOnce
{{ header }}

const regAddress = baseAddress + {{ addressoffset }}
@regdef struct {{ prefix }}{{ name }}{{ postfix }}Struct(regAddress)
{{# fieldranges }}
    {{ name }}: {{ length }}{{# access}}::{{ access }}{{/ access}}
{{/ fieldranges }}
end

const Reg = {{ prefix }}{{ name }}{{ postfix }}Struct

{{# fielddescriptions }}
"""
    {{ name}}

{{ description }}
"""
{{ name }}
{{/ fielddescriptions }}
end # register {{ name }}

