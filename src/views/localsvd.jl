struct LocalSVD
    svdpath::String
end

function view(l::LocalSVD, dir::String) 
    # Project was generated, copy SVD
    svddestpath = joinpath(dir, "src", "SVD")
    mkpath(svddestpath)
    cp(l.svdpath, joinpath(svddestpath, basename(l.svdpath)); force=true)
    return nothing
end
