using PICDataStructures, Test
using PICDataStructures: dimensionality, unitname, unwrapdata
using Unitful
using RecursiveArrayTools: recursive_bottom_eltype

@testset "Scalar field interface" begin
    grids =
        SparseAxisGrid(1:0.1:2),
        SparseAxisGrid(1:0.01:2, 1:0.01:2),
        SparseAxisGrid(1:0.005:2, 1:0.01:2, 1:0.01:2),
        SparseAxisGrid(1u"m":0.1u"m":2.0u"m"),
        SparseAxisGrid(1u"m":0.01u"m":2u"m", 1u"m":0.01u"m":2u"m"),
        SparseAxisGrid(1u"m":0.005u"m":2u"m", 1u"m":0.01u"m":2u"m", 1u"m":0.01u"m":2u"m")

    fields = [
        scalarfield(x->inv(x...), grids[1], name="1D"),
        scalarfield(grids[2], name="2D") do (x,y)
            1 / √(x^2 + y^2)
        end,
        scalarfield(grids[3], name="3D") do (x,y,z)
            1 / √(x^2 + y^2 + z^2)
        end,
        scalarfield(grids[4], name="1D") do (x,)
            1u"V" / x
        end,
        scalarfield(grids[5], name="2D") do (x,y)
            1u"V" / √(x^2 + y^2)
        end,
        scalarfield(grids[6], name="3D") do (x,y,z)
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
            𝟙 = oneunit(recursive_bottom_eltype(f))
            @test f[begin] == f[1] == 𝟙 / √N
            @test f[end] == 𝟙 / √(4*N)
        end
        @testset "Iteration" begin
            @test [fd for fd in f] == collect(f)
        end
        @testset "Broadcasting" begin
            f2 = f .* 2
            @test typeof(f) == typeof(f2)
            @test getdomain(f2) == getdomain(f)
            @test 2f[1] == f2[1]
            @test nameof(f) == nameof(f2)
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
            @test nameof(f) == nameof(f_small) == "$(N)D"
        end
    end

    @testset "Sclicing" begin
        @testset "2D" begin
            N = 2
            fi = fields[2]
            grid = grids[2]
            f_extra = scalarfield(grid) do (x,y)
                0.5x - grid.x[1]
            end
            f = fi + f_extra

            f_slice = selectdim(f, :x, grid.x[1])
            @test ndims(f_slice) == N - 1
            @test dimensionality(f_slice) == N - 1
            @test f[1] == f_slice[1]
            @test f[1,:] == f_slice

            mid = (grid.y[end] + grid.y[begin])/2
            f_slice = selectdim(f, :y, mid)
            @test ndims(f_slice) == N - 1
            @test dimensionality(f_slice) == N - 1
            l = length(grid.y)
            @test f[:,l÷2+1] == f_slice

            f_slice = selectdim(f, :y, grid.y[1])
            @test ndims(f_slice) == N - 1
            @test dimensionality(f_slice) == N - 1
            @test f[:,1] == f_slice

            @test nameof(f) == nameof(f_slice) == "2D"
        end
        @testset "3D" begin
            N = 3
            fi = fields[3]
            grid = grids[3]
            f_extra = scalarfield(grid) do (x,y)
                0.3x - grid.x[1]
            end
            f = fi + f_extra

            f_slice = selectdim(f, :x, grid.x[1])
            @test ndims(f_slice) == N - 1
            @test dimensionality(f_slice) == N - 1
            @test f[1] == f_slice[1]
            @test f[1,:,:] == f_slice

            mid = (grid.y[end] + grid.y[begin])/2
            f_slice = selectdim(f, :y, mid)
            @test ndims(f_slice) == N - 1
            @test dimensionality(f_slice) == N - 1
            l = length(grid.y)
            @test f[:,l÷2+1,:] == f_slice

            f_slice = selectdim(f, :z, grid.y[1])
            @test ndims(f_slice) == N - 1
            @test dimensionality(f_slice) == N - 1
            @test f[:,:,1] == f_slice

            @test nameof(f) == nameof(f_slice) == "3D"
        end
    end

    @testset "Unit handling" begin
        @test ustrip(fields[4]) == fields[1]
        @test ustrip(fields[5]) == fields[2]
        @test ustrip(fields[6]) == fields[3]

        @test fields[1] .* u"V/m" == fields[4]
        @test fields[2] .* u"V/m" == fields[5]
        @test fields[3] .* u"V/m" == fields[6]

        @test ustrip(u"V/m", fields[4]) == fields[1]
        @test ustrip(u"V/m", fields[5]) == fields[2]
        @test ustrip(u"V/m", fields[6]) == fields[3]

        @test ustrip(u"V/m", u"m", fields[4]) == fields[1]
        @test ustrip(u"V/m", u"m", fields[5]) == fields[2]
        @test ustrip(u"V/m", u"m", fields[6]) == fields[3]

        @test ustrip(fields[1]) == fields[1]
        @test nameof(ustrip(fields[1])) == "1D"

        @test nameof(ustrip(u"V/m", fields[1])) == "1D"
        @test nameof(ustrip(u"V/m", u"m", fields[1])) == "1D"
    end
end

@testset "Scalar variable interface" begin
    grids = [
        ParticlePositions(collect.((0:0.1:1,0:0.1:1))...),
        ParticlePositions(collect.(((0:0.1:1).*u"m",(0:0.1:1).*u"m"))...),
        ParticlePositions(collect.((0:0.1:1,0:0.1:1,0:0.1:1))...),
        ParticlePositions(collect.(((0:0.1:1).*u"m",(0:0.1:1).*u"m",(0:0.1:1).*u"m"))...),
    ]
    vars = [
        scalarvariable(grids[1], name="2D") do (x,y)
            x^2 + y^2
        end,
        scalarvariable(grids[2], name="2D") do (x,y)
            x^2 + y^2
        end,
        scalarvariable(grids[3], name="3D") do (x,y,z)
            x^2 + y^2 + z^2
        end,
        scalarvariable(grids[4], name="3D") do (x,y,z)
            x^2 + y^2 + z^2
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
            @test 2v[end] == v2[end]
            @test nameof(v2) == nameof(v)
        end

        @testset "Downsampling" begin
            v_small = downsample(v, 5)
            @test size(v_small) == (5,)
            v_small = downsample(v)
            @test all(size(v_small) .≤ size(v))
            @test nameof(v) == nameof(v_small)
        end
    end

    @testset "Sclicing" begin
        @testset "2D" begin
            v = vars[1]
            v_slice = selectdim(v, :x, 0.0, ϵ=0.1)
            @test dimensionality(v_slice) == 1
            @test size(v_slice) == size(getdomain(v_slice))
            @test length(v_slice) == 2
            @test v_slice ≈ [0.0, 0.02]
            @test nameof(v) == nameof(v_slice) == "2D"
        end
        @testset "3D" begin
            v = vars[3]
            v_slice = selectdim(v, :x, 0.0, ϵ=0.1)
            @test dimensionality(v_slice) == 2
            @test size(v_slice) == size(getdomain(v_slice))
            @test length(v_slice) == 2
            @test v_slice ≈ [0.0, 0.03]
            @test nameof(v) == nameof(v_slice) == "3D"
        end
    end

    @testset "Unit handling" begin
        v = vars[1]
        v_u = vars[2]

        @test all(ustrip(v_u) .≈ v)
        @test all(v .* 1u"m^2" .≈ v_u)
        @test nameof(ustrip(v_u)) == nameof(v)
    end
end
