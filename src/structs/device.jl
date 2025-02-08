@kwdef mutable struct Device
    vendor::Option{String} = nothing
    vendorID::Option{String} = nothing
    name::String
    series::Option{String} = nothing
    version::String
    description::String
    licenseText::Option{String} = nothing
    cpu::CPU
    headerSystemFilename::Option{String} = nothing
    headerDefinitionsPrefix::Option{String} = nothing
    addressUnitBits::SNNI
    width::SNNI
    rpg::RegisterPropertiesGroup = RegisterPropertiesGroup()
    peripherals::Vector{Peripheral} = Peripheral[]
    vendorExtensions::Vector{Any} = []
end

