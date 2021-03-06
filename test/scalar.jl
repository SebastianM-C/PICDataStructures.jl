using PICDataStructures, Test
using Unitful

@testset "Scalar field interface" begin
    grids = [
        (0:0.1:1,),
        (0:0.01:1, 0:0.01:1),
        (0:0.005:1, 0:0.01:1, 0:0.01:1),
        (0:0.1:1,).*u"m",
        (0:0.01:1, 0:0.01:1).*u"m",
        (0:0.005:1, 0:0.01:1, 0:0.01:1).*u"m",
    ]
    data_sets = [
        sin.(grids[1][1]),
        [sin(x)*sin(y) for (x,y) in Iterators.product(grids[2]...)],
        [sin(x)*sin(y)*sin(z) for (x,y,z) in Iterators.product(grids[3]...)],
        sin.(grids[1][1]).*u"V/m",
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
        @test f.grid == grid

        T = typeof(f)
        @test isconcretetype(T)

        @testset "Traits" begin
            @test scalarness(T) === ScalarQuantity()
            @test domain_discretization(T) === LatticeGrid()
            @test domain_type(T) === Tuple
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
            @test f2.grid == f.grid
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

        @testset "Sclice" begin
            # TODO: Add tests
        end
    end
end

@testset "Scalar variable interface" begin
    grid = collect(0:0.1:1)
    data_sets = [
        sin.(grid),
        sin.(grid).*u"V/m",
    ]
    desc = [
        "unitless",
        "Unitful",
    ]

    @testset "$(desc[i])" for i in eachindex(desc)
        data = data_sets[i]
        f = ScalarVariable(data, grid)
        @test f.data == data
        @test f.grid == grid

        T = typeof(f)
        @test isconcretetype(T)

        @testset "Traits" begin
            @test scalarness(T) === ScalarQuantity()
            @test domain_discretization(T) === ParticleGrid()
            @test domain_type(T) === Array
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
            @test f2.grid == f.grid
        end

        @testset "Downsampling" begin
            @test_throws MethodError f_small = downsample(f, 5)
            @test_broken size(f_small) == (5,)
        end

        @testset "Sclice" begin
            # TODO: Add tests
        end
    end
end
