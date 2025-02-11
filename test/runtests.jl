using DeviceDefinitions
using Test
using Tar, Inflate, Downloads

@testset "All Tests" begin

@testset "Basic Example" begin
    svdpath = joinpath(@__DIR__, "example.svd")
    device = DeviceDefinitions.readSVD(svdpath)
    @testset "Read basic example" begin
        @test device isa DeviceDefinitions.Device
    end
    @testset "Generate Basic Example" begin
        mktempdir() do path
            generationexpression = [
                "generation" => :(DeviceDefinitions.generate("Example", $svdpath, parentdir=$path)),
                "regeneration" => :(DeviceDefinitions.generate(joinpath($path, "Example.jl")))
            ]
            @testset "Testing $mtd." for (mtd,genexpr) in generationexpression
                eval(genexpr)
                @test "Example.jl" in readdir(path)
                for (obj, _file) in (("src",false), 
                                     ("Project.toml",true), 
                                     ("Manifest.toml",true), 
                                     (".gitignore",true))
                    @test obj in readdir(joinpath(path, "Example.jl"))
                    if _file
                        @test isfile(joinpath(path, "Example.jl", obj))
                    else
                        @test isdir(joinpath(path, "Example.jl", obj))
                    end
                end
                for (obj, _file) in (("peripherals.jl",true), 
                                     ("peripherals",false), 
                                     ("SVD",false), 
                                     ("Example.jl",true))
                    @test obj in readdir(joinpath(path, "Example.jl", "src"))
                    if _file
                        @test isfile(joinpath(path, "Example.jl", "src", obj))
                    else
                        @test isdir(joinpath(path, "Example.jl", "src", obj))
                    end
                end
                @test length(readdir(joinpath(path, "Example.jl", "src", "peripherals"))) == length(device.peripherals)
            end
        end
    end
end

@testset "Test artifact svd file" begin
    url = "https://github.com/Seelengrab/DeviceDefinitions.jl/archive/22b9ba65a2d4974c2866a775dc61a8bc88f92b7a.tar.gz"
    filename = joinpath("DeviceDefinitions.jl-22b9ba65a2d4974c2866a775dc61a8bc88f92b7a", "test", "example.svd")
    destdir = Tar.extract(x->x.path==filename, IOBuffer(inflate_gzip(Downloads.download(url))))
    svdpath = joinpath(destdir, filename)
    device = DeviceDefinitions.readSVD(svdpath)
    mktempdir() do path
        generationexpression = [
            "generation" => :(DeviceDefinitions.generate("Example", $url, $filename, parentdir=$path)),
            "regeneration" => :(DeviceDefinitions.generate(joinpath($path, "Example.jl")))
        ]
        @testset "Testing $mtd." for (mtd,genexpr) in generationexpression
            eval(genexpr)
            @test "Example.jl" in readdir(path)
            for (obj, _file) in (("src",false), 
                ("Project.toml",true), 
                ("Manifest.toml",true), 
                (".gitignore",true))
                @test obj in readdir(joinpath(path, "Example.jl"))
                if _file
                    @test isfile(joinpath(path, "Example.jl", obj))
                else
                    @test isdir(joinpath(path, "Example.jl", obj))
                end
            end
            for (obj, _file) in (("peripherals.jl",true), 
                ("peripherals",false), 
                ("Example.jl",true))
                @test obj in readdir(joinpath(path, "Example.jl", "src"))
                if _file
                    @test isfile(joinpath(path, "Example.jl", "src", obj))
                else
                    @test isdir(joinpath(path, "Example.jl", "src", obj))
                end
            end
            @test length(readdir(joinpath(path, "Example.jl", "src", "peripherals"))) == length(device.peripherals)
            @test isfile(joinpath(path, "Example.jl", "Artifacts.toml"))
        end
    end
end


end # all tests
