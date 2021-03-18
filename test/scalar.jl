using PICDataStructures, Test
using Unitful

@testset "Scalar field interface" begin
    grids = SparseAxisGrid.([
        (0:0.1:1,),
        (0:0.01:1, 0:0.01:1),
        (0:0.005:1, 0:0.01:1, 0:0.01:1),
        (0:0.1:1,).*u"m",
        (0:0.01:1, 0:0.01:1).*u"m",
        (0:0.005:1, 0:0.01:1, 0:0.01:1).*u"m",
    ])
    data_sets = [
        sin.(first(grids[1])),
        [sin(x)*sin(y) for (x,y) in Iterators.product(grids[2]...)],
        [sin(x)*sin(y)*sin(z) for (x,y,z) in Iterators.product(grids[3]...)],
        sin.(first(grids[1])).*u"V/m",
        [sin(x)*sin(y)u"V/m" for (x,y) in Iterators.product(grids[2]...)],
        [sin(x)*sin(y)*sin(z)u"V/m" for (x,y,z) in Iterators.product(grids[3]...)]
    ]
    desc = [
        "1D",
        "2D",
        "3D",
        "1D Unitful",
        "2D Unitful",
        "3D Unitful"
    ]

    @testset "$(desc[i])" for i in eachindex(desc)
        data = data_sets[i]
        grid = grids[i]
        f = ScalarField(data, grid)
        @test f.data == data
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
            if startswith(desc[i], "3D")
                f_small = downsample(f, 150, 50, 50)
            elseif startswith(desc[i], "2D")
                f_small = downsample(f, 50, 50)
            else
                f_small = downsample(f, 5)
            end
            if startswith(desc[i], "3D")
                @test size(f_small) == (150, 50, 50)
            elseif startswith(desc[i], "2D")
                @test size(f_small) == (50, 50)
            else
                @test size(f_small) == (5,)
            end
        end
    end
    @testset "Sclicing" begin
        data = data_sets[3]
        grid = grids[3]

        f = ScalarField(data, grid)

        fs = slice(f, 1, 5)
        fs1 = slice(f, 1, 0.5)
        @test f[5, :, :] == fs
    end

    @testset "Unit handling" begin
        data = data_sets[3]
        grid = grids[3]
        data_u = data_sets[6]
        grid_u = grids[6]

        f = ScalarField(data, grid)
        f_u = ScalarField(data_u, grid_u)

        @test ustrip(f_u) == f
    end
end

@testset "Scalar variable interface" begin
    grid = ParticlePositions((collect(0:0.1:1),), (0.,), (1.,))
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
