{{!/* vim: set filetype=mustache: */}}
{{!
Definition of a device's peripherals. It expects a context type `PeripheralsDefinitionContext`. See src/views.jl.
}}
module Peripherals

{{! We explicitely don't finish the module here, as we need to include the registers and clusters children }}
