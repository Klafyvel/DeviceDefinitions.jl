function getdevice(strategy::LocalSVD, _, _)
    return readSVD(strategy.svdpath)
end

function getdevice(::ExistingSVD, projectdir, modulename)
    julia = joinpath(Sys.BINDIR, Base.julia_exename())
    cmd = `$julia -e "import $modulename; println($modulename.svdpath())"`
    io = IOBuffer()
    withenv("JULIA_PROJECT"=>projectdir) do 
        run(pipeline(cmd, stdout=io))
    end
    path = chomp(String(take!(io)))
    return readSVD(path)
end

function getdevice(strategy::ArtifactSVD, _, _)
    return readSVD(strategy.downloadedsvdpath)
end


