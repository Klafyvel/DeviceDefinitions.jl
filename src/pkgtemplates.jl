"""
    DeviceDefinition(
        file=nothing,
        url=nothing,
    )

Generate a package for a MCU from an SVD file. The SVD file can either be sourced
from a tarball on the web, in which case `file` refers to the path to the SVD file 
within the tarball and `url` to the url of the tarball, or from a local file, when 
`url` is `nothing`. In the former case, the source SVD file will be added to the 
package as an artifact. In the latter it will be included in the repository.

!!! note
This plugin will overwrite the output of the SrcDir plugin.
"""
@plugin struct DeviceDefinition <: Plugin
    file::Union{String, Nothing} = nothing
    url::Union{String, Nothing} = nothing
end

function PkgTemplates.validate(d::DeviceDefinition, template::PkgTemplates.Template)
    if isnothing(d.file)
        if !isnothing(d.url)
            throw(ArgumentError("A file (path to the SVD file from the root of the archive) needs to be specified when giving an url."))
        else
            throw(ArgumentError("An SVD file must be specified in the input."))
        end
    end
    if !isnothing(PkgTemplates.getplugin(template, PkgTemplates.SrcDir))
        @warn "DeviceDefinition will overwrite the output of the SrcDir plugin."
    end
end

function PkgTemplates.prehook(d::DeviceDefinition, t::PkgTemplates.Template, pkg_dir::AbstractString)
    mkpath(joinpath(pkg_dir, "src"))
    # Trick to avoid precompilation failing
    modulename = PkgTemplates.pkg_name(pkg_dir)
    open(joinpath(pkg_dir, "src", modulename*".jl"), "w") do io 
        write(io, "module $modulename\nend\n")
    end
end

function PkgTemplates.hook(d::DeviceDefinition, t::PkgTemplates.Template, pkg_dir::AbstractString)
    # Add dependencies
    view(PkgProject(), pkg_dir)
    # Copy SVD file or create the artifact
    svdstrategy = if isnothing(d.url)
        LocalSVD(d.file)
    else
        ArtifactSVD(d.url, d.file)
    end
    view(svdstrategy, pkg_dir)
    # Generate the julia binding
    modulename = PkgTemplates.pkg_name(pkg_dir)
    device = getdevice(svdstrategy, pkg_dir, modulename)
    view(DeviceProject(device, modulename, svdstrategy), pkg_dir)
end

PkgTemplates.input_tips(::Type{DeviceDefinition}) = [
    "To include a local file, leave `url` set to `nothing`."
    "Otherwise, `url` should point to a tarball, and `file` should be the path to the SVD file within the tarball."
]

"""
Default plugins used by [`generate`](@ref).
"""
const DEFAULT_PLUGINS = [
    !(PkgTemplates.SrcDir),
    PkgTemplates.ProjectFile(; version=v"0.1"),
    PkgTemplates.Tests(aqua=true, jet=true),
    PkgTemplates.Readme(),
    PkgTemplates.License(),
    PkgTemplates.Git(ssh=true),
    PkgTemplates.GitHubActions(),
    PkgTemplates.CompatHelper(),
    PkgTemplates.TagBot(),
    PkgTemplates.Dependabot(),
    PkgTemplates.Documenter{PkgTemplates.GitHubActions}()
]
