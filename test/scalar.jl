using PICDataStructures, Test
using PICDataStructures: dimensionality, unitname
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
        scalarfield(x->inv(x...), grids[1]),
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
        N = dimensionality(f)
        @test isconcretetype(T)

        @testset "Traits" begin
            @test scalarness(T) === ScalarQuantity()
            @test domain_discretization(T) === LatticeGrid{N}()
            @test domain_type(T) <: SparseAxisGrid
        end

        @testset "Indexing" begin
            @test size(f) == size(grid)
            @test !isfinite(f[1])
            @test f[end] == oneunit(recursive_bottom_eltype(f)) / √N
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
            if N == 3
                f_small = downsample(f, 150, 50, 50)
                @test size(f_small) == (150, 50, 50)
                f_small = downsample(f)
                # in case the downsampling size is too close
                # to the target one, we will get the same size
                @test size(f_small) == size(f)
                f_small = downsample(f, approx_size=50)
                @test all(size(f_small) .≤ 50)
            elseif N == 2
                f_small = downsample(f, 50, 50)
                @test size(f_small) == (50, 50)
                f_small = downsample(f)
                @test all(size(f_small) .≤ 160)
            else
                f_small = downsample(f, 5)
                @test size(f_small) == (5,)
            end
        end

        @testset "Sclicing" begin
            if N > 1
                f_slice = selectdim(f, :x, zero(recursive_bottom_eltype(grid)))
                @test ndims(f_slice) == N - 1
                @test dimensionality(f_slice) == N - 1
            end
        end
    end

    @testset "Unit handling" begin
        @test ustrip(fields[4]) == fields[1]
        @test ustrip(fields[5]) == fields[2]
        @test ustrip(fields[6]) == fields[3]

        @test fields[1] .* u"V/m" == fields[4]
        @test fields[2] .* u"V/m" == fields[5]
        @test fields[3] .* u"V/m" == fields[6]
    end
end

@testset "Scalar variable interface" begin
    grids = [
        ParticlePositions((collect(0:0.1:1),collect(0:0.1:1))),
        ParticlePositions((collect(0:0.1:1).*u"m",collect(0:0.1:1).*u"m"))
    ]
    vars = [
        scalarvariable(grids[1]) do (x,y)
            x^2 + y^2
        end,
        scalarvariable(grids[2]) do (x,y)
            (x^2 + y^2)
        end,
    ]

    @testset "$(dimensionality(v))D ($(unitname(v)))" for (grid,v) in zip(grids,vars)
        @test v isa ScalarVariable
        @test getdomain(v) == grid
        @test ndims(v) == 1

        T = typeof(v)
        N = dimensionality(v)
        @test isconcretetype(T)

        @testset "Traits" begin
            @test scalarness(T) === ScalarQuantity()
            @test domain_discretization(T) === ParticleGrid()
            @test domain_type(T) <: ParticlePositions
        end

        @testset "Indexing" begin
            @test size(v) == size(grid)
            @test iszero(v[1])
            @test v[1] isa Number
        end
        @testset "Iteration" begin
            @test [fd for fd in v] == collect(v)
        end
        @testset "Broadcasting" begin
            v2 = v .* 2
            @test typeof(v) == typeof(v2)
            @test v2.grid == getdomain(v)
        end

        @testset "Downsampling" begin
            f_small = downsample(v, 5)
            @test size(f_small) == (5,)
            v_small = downsample(v)
            @test all(size(v_small) .≤ size(v))
        end

        @testset "Sclicing" begin
            t = recursive_bottom_eltype(grid)
            f_slice = selectdim(v, :x, zero(t), ϵ=t(1e-3))
            @test dimensionality(f_slice) == N - 1
        end
    end

    @testset "Unit handling" begin
        v = vars[1]
        v_u = vars[2]

        @test all(ustrip(v_u) .≈ v)
        @test all(v .* 1u"m^2" .≈ v_u)
    end
end
