using Inflate, Tar, SHA, Downloads

"Path to the mustache template for Artifacts.toml file."
const ARTIFACTS_TEMPLATE_PATH = Ref{String}(joinpath(TEMPLATES_DIRECTORY[], "Artifacts.tpl"))

"Mustache template for devices."
const ARTIFACTS_TEMPLATE = Ref{Mustache.MustacheTokens}(Mustache.load(ARTIFACTS_TEMPLATE_PATH[]))
mutable struct ArtifactSVD
    url::String
    filename::String
    downloadedpath::Union{String, Nothing}
    downloadedtarpath::Union{String,Nothing}
    downloadedsvdpath::Union{String,Nothing}
end

function Base.getproperty(a::ArtifactSVD, name::Symbol)
    if name == :downloadedsvdpath 
        !isnothing(getfield(a, :downloadedsvdpath)) && return getfield(a, :downloadedsvdpath)
        @info "Extracting SVD file..."
        tarpath = a.downloadedtarpath
        setfield!(a, :downloadedsvdpath, joinpath(Tar.extract(x->x.path==a.filename, tarpath), a.filename))
        return getfield(a, :downloadedsvdpath)
    elseif name == :downloadedtarpath
        !isnothing(getfield(a, :downloadedtarpath)) && return getfield(a, :downloadedtarpath)
        @info "Deflating SVD tarball..."
        gzpath = a.downloadedpath
        destpath, io = mktemp()
        setfield!(a, :downloadedtarpath, destpath)
        write(io, inflate_gzip(gzpath))
        close(io)
        return destpath
    elseif name == :downloadedpath
        !isnothing(getfield(a, :downloadedpath)) && return getfield(a, :downloadedpath)
        @info "Downloading $(a.url)..."
        setfield!(a, :downloadedpath, Downloads.download(a.url))
        return getfield(a, :downloadedpath)
    else
        return getfield(a, name)
    end
end

struct ArtifactsContext 
    git_tree_sha1::String
    url::String
    download_sha256::String
end

function view(artifact::ArtifactSVD, dir::String) 
    mainmodulepath = joinpath(dir, "Artifacts.toml")
    return open(mainmodulepath, "w") do io
        view(io, artifact, dir)
    end
end

function view(io::IO, artifact::ArtifactSVD, basedir)
    context = ArtifactsContext(
        Tar.tree_hash(IOBuffer(read(artifact.downloadedtarpath))),
        artifact.url,
         bytes2hex(open(sha256, artifact.downloadedpath))
    )
    ARTIFACTS_TEMPLATE[](io, context)
    return nothing
end


