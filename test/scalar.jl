using PICDataStructures, Test
using Unitful

@testset "Scalar field interface" begin
    grids = [
        (0:0.1:1,),
        (0:0.1:1, 0:0.1:1),
        (0:0.1:1, 0:0.1:1, 0:0.1:1),
        (0:0.1:1,).*u"m",
        (0:0.1:1, 0:0.1:1).*u"m",
        (0:0.1:1, 0:0.1:1, 0:0.1:1).*u"m",
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
    end
end
