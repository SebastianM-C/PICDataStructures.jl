using PICDataStructures, Test
using LinearAlgebra
using Unitful

@testset "Vector field interface" begin
    grid = (0:0.01:1, 0:0.01:1)
    data = [sin(x)*sin(y) for (x,y) in Iterators.product(grid...)]

    f = ScalarField(data, grid)

    vf = build_vector((f, f), (:x, :y))

    T = typeof(vf)
    @test isconcretetype(T)

    @testset "Traits" begin
        @test scalarness(T) === VectorQuantity()
        @test domain_discretization(T) === LatticeGrid()
        @test domain_type(T) === Tuple
    end

    @test isconcretetype(typeof(vf))
    @test vf.x == f

    nvf = norm(vf)

    @test scalarness(typeof(nvf)) === ScalarQuantity()
    @test norm(vf[2,10]) == nvf[2,10]
end

@testset "Vector variable interface" begin
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
        sv = ScalarVariable(data, grid)
        v = build_vector((sv, sv), (:x, :y))

        @test v.grid == grid

        T = typeof(v)
        @test isconcretetype(T)
        @test v.x == sv

        @testset "Traits" begin
            @test scalarness(T) === VectorQuantity()
            @test domain_discretization(T) === ParticleGrid()
            @test domain_type(T) === Array
        end

        nvf = norm(v)
        @test scalarness(typeof(nvf)) === ScalarQuantity()
        @test norm(v[2]) == nvf[2]
    end
end
