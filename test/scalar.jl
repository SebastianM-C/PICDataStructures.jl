using PICDataStructures, Test
using PICDataStructures: unitname, dimensionality
using Unitful
using RecursiveArrayTools: recursive_bottom_eltype

@testset "Scalar field interface" begin
    grids = SparseAxisGrid.([
        (0:0.1:1,),
        (0:0.01:1, 0:0.01:1),
        (0:0.005:1, 0:0.01:1, 0:0.01:1),
        (0:0.1:1,).*u"m",
        (0:0.01:1, 0:0.01:1).*u"m",
        (0:0.005:1, 0:0.01:1, 0:0.01:1).*u"m",
    ])
    fields = [
        scalarfield(grids[1]) do (x,)
            1 / x
        end,
        scalarfield(grids[2]) do (x,y)
            1 / √(x^2 + y^2)
        end,
        scalarfield(grids[3]) do (x,y,z)
            1 / √(x^2 + y^2 + z^2)
        end,
        scalarfield(grids[4]) do (x,)
            1u"V" / x
        end,
        scalarfield(grids[5]) do (x,y)
            1u"V" / √(x^2 + y^2)
        end,
        scalarfield(grids[6]) do (x,y,z)
            1u"V" / √(x^2 + y^2 + z^2)
        end
    ]

    @testset "$(dimensionality(f))D ($(unitname(f)))" for (grid,f) in zip(grids,fields)
        @test f isa ScalarField
        @test getdomain(f) == grid

        T = typeof(f)
        N = length(grid)
        @test isconcretetype(T)

        @testset "Traits" begin
            @test scalarness(T) === ScalarQuantity()
            @test domain_discretization(T) === LatticeGrid{N}()
            @test domain_type(T) <: SparseAxisGrid
        end

        @testset "Indexing" begin
            @test size(f) == size(grid)
            @test !isfinite(f[1])
            @test f[end] == oneunit(recursive_bottom_eltype(f)) / √(dimensionality(f))
        end
        @testset "Iteration" begin
            @test [fd for fd in f] == collect(f)
        end
        @testset "Broadcasting" begin
            f2 = f .* 2
            @test typeof(f) == typeof(f2)
            @test getdomain(f2) == getdomain(f)
            @test f[1] == 2*f2[1]
        end

        @testset "Downsampling" begin
            if dimensionality(f) == 3
                f_small = downsample(f, 150, 50, 50)
                @test size(f_small) == (150, 50, 50)
            elseif dimensionality(f) == 2
                f_small = downsample(f, 50, 50)
                @test size(f_small) == (50, 50)
            else
                f_small = downsample(f, 5)
                @test size(f_small) == (5,)
            end
        end
    end
    @testset "Sclicing" begin
        f = fields[3]

        fs = slice(f, 1, 5)
        fs1 = slice(f, 1, 0.5)
        @test f[5, :, :] == fs
        @test dimensionality(fs) == 2
    end

    @testset "Unit handling" begin
        @test ustrip(fields[4]) == fields[1]
        @test ustrip(fields[5]) == fields[2]
        @test ustrip(fields[6]) == fields[3]
    end
end

@testset "Scalar variable interface" begin
    grid = ParticlePositions((collect(0:0.1:1),))
    data_sets = [
        sin.(first(grid)),
        sin.(first(grid)).*u"V/m",
    ]
    desc = [
        "unitless",
        "Unitful",
    ]

    @testset "$(desc[i])" for i in eachindex(desc)
        data = data_sets[i]
        f = ScalarVariable(data, grid)
        @test f.data == data
        @test getdomain(f) == grid

        T = typeof(f)
        @test isconcretetype(T)

        @testset "Traits" begin
            @test scalarness(T) === ScalarQuantity()
            @test domain_discretization(T) === ParticleGrid()
            @test domain_type(T) <: ParticlePositions
        end

        @testset "Indexing" begin
            @test size(f) == size(data)
            @test f[begin:end] == data[begin:end]
        end
        @testset "Iteration" begin
            @test all([fd == d for (fd, d) in zip(f, data)])
        end
        @testset "Broadcasting" begin
            f2 = f .* 2
            @test typeof(f) == typeof(f2)
            @test f2.grid == getdomain(f)
        end

        @testset "Downsampling" begin
            f_small = downsample(f, 5)
            @test size(f_small) == (5,)
        end

        @testset "Sclice" begin
            # TODO: Add tests
        end
    end

    @testset "Unit handling" begin
        data = data_sets[1]
        data_u = data_sets[2]

        f = ScalarVariable(data, grid)
        f_u = ScalarVariable(data_u, grid)

        @test ustrip(f_u) == f
    end
end
