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

    @test vf.x == f

    @test vf[1,:] == getfield(vf, :data)[1,:]

    @testset "Broadcasting" begin
        vf2 = vf .* 2
        @test vf .* 1 == vf
        @test typeof(vf2) == typeof(vf)
        @test getfield(vf2, :grid) == getfield(vf, :grid)
    end

    @testset "LinearAlgebra" begin
        nvf = norm(vf)
        @test scalarness(typeof(nvf)) === ScalarQuantity()
        @test norm(vf[2]) == nvf[2]
    end
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

        @test getfield(v, :grid) == grid

        @test v[1,:] == getfield(v, :data)[1,:]

        T = typeof(v)
        @test isconcretetype(T)
        @test v.x == sv

        @testset "Traits" begin
            @test scalarness(T) === VectorQuantity()
            @test domain_discretization(T) === ParticleGrid()
            @test domain_type(T) === Array
        end

        @testset "Broadcasting" begin
            v2 = v .* 2
            @test v .* 1 == v
            @test typeof(v2) == typeof(v)
            @test getfield(v2, :grid) == getfield(v, :grid)
        end

        @testset "LinearAlgebra" begin
            nvf = norm(v)
            @test scalarness(typeof(nvf)) === ScalarQuantity()
            @test norm(v[2]) == nvf[2]
        end
    end
end
