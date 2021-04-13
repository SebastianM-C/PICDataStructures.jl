using PICDataStructures, Test
using LinearAlgebra
using Unitful

@testset "Vector field interface" begin
    grid = SparseAxisGrid((0:0.01:1, 0:0.01:1, 0:0.1:1))
    f = scalarfield(grid) do (x,y,z)
        sin(x)*sin(y)
    end

    vf = build_vector((f, -f, f.^2), (:x, :y, :z))

    T = typeof(vf)
    @test isconcretetype(T)

    @testset "Traits" begin
        @test scalarness(T) === VectorQuantity()
        @test domain_discretization(T) === LatticeGrid{3}()
        @test domain_type(T) <: SparseAxisGrid
    end

    @test vf.x == f

    @test vf[1,:,:] == getfield(vf, :data)[1,:,:]

    @testset "Broadcasting" begin
        vf2 = vf .* 2
        @test vf .* 1 == vf
        @test typeof(vf2) == typeof(vf)
        @test getfield(vf2, :grid) == getdomain(vf)
    end

    @testset "LinearAlgebra" begin
        nvf = norm(vf)
        @test scalarness(typeof(nvf)) === ScalarQuantity()
        @test norm(vf[2]) == nvf[2]

        @test all(iszero.(vf × vf))
    end
end

@testset "Vector variable interface" begin
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
        sv = ScalarVariable(data, grid)
        v = build_vector((sv, sv), (:x, :y))

        @test getdomain(v) == grid

        @test v[1,:] == getfield(v, :data)[1,:]

        T = typeof(v)
        @test isconcretetype(T)
        @test v.x == sv

        @testset "Traits" begin
            @test scalarness(T) === VectorQuantity()
            @test domain_discretization(T) === ParticleGrid()
            @test domain_type(T) <: ParticlePositions
        end

        @testset "Broadcasting" begin
            v2 = v .* 2
            @test v .* 1 == v
            @test typeof(v2) == typeof(v)
            @test getfield(v2, :grid) == getdomain(v)
        end

        @testset "LinearAlgebra" begin
            nvf = norm(v)
            @test scalarness(typeof(nvf)) === ScalarQuantity()
            @test norm(v[2]) == nvf[2]
        end
    end

    @testset "Units" begin
        data1 = data_sets[1]
        data2 = data_sets[2]
        sv1 = ScalarVariable(data1, grid)
        sv2 = ScalarVariable(data2, grid)
        v1 = build_vector((sv1, sv1), (:x, :y))
        v2 = build_vector((sv2, sv2), (:x, :y))

        @test ustrip(v2) == v1
    end
end
