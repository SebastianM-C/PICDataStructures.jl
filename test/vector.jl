using PICDataStructures, Test
using PICDataStructures: dimensionality, unitname
using LinearAlgebra
using RecursiveArrayTools: recursive_bottom_eltype
using Unitful
using StaticArrays

@testset "Vector field interface" begin
    grids =
        SparseAxisGrid(0.001:0.01:1),
        SparseAxisGrid(0.001:0.01:1, 0:0.01:1),
        SparseAxisGrid(0.001:0.005:1, 0:0.01:1, 0:0.01:1),
        SparseAxisGrid(0.001u"m":0.01u"m":1u"m"),
        SparseAxisGrid(0.001u"m":0.01u"m":1u"m", 0u"m":0.01u"m":1u"m"),
        SparseAxisGrid(0.001u"m":0.005u"m":1u"m", 0u"m":0.01u"m":1u"m", 0u"m":0.01u"m":1u"m")

    scalar_fields = [
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
    fields = [
        build_vector((scalar_fields[1], ), (:x,), name="1D"),
        build_vector((scalar_fields[2], scalar_fields[2]), (:x, :y), name="2D"),
        build_vector((scalar_fields[3], scalar_fields[3], scalar_fields[3]), (:x, :y, :z), name="3D"),
        build_vector((scalar_fields[4], ), (:x,), name="1D"),
        build_vector((scalar_fields[5], scalar_fields[5]), (:x, :y), name="2D"),
        build_vector((scalar_fields[6], scalar_fields[6], scalar_fields[6]), (:x, :y, :z), name="3D")
    ]

    @testset "$(dimensionality(f))D ($(unitname(f)))" for (grid,s,f) in zip(grids,scalar_fields,fields)
        T = typeof(f)
        N = dimensionality(f)
        @test isconcretetype(T)

        @testset "Traits" begin
            @test scalarness(T) === VectorQuantity()
            @test domain_discretization(T) === LatticeGrid{N}()
            @test domain_type(T) <: SparseAxisGrid
        end

        @test f.x == s

        @testset "Indexing" begin
            @test size(f) == size(grid)
            t = recursive_bottom_eltype(f)
            @test all(f[1] .== t(1000))
            @test f[1] isa SVector
            @test f[1,:,:] == getfield(f, :data)[1,:,:]
            @test f[end][1] .≈ oneunit(t) / √N atol=t(1e-2)
        end

        @testset "Broadcasting" begin
            f2 = f .* 2
            @test f .* 1 == f
            @test typeof(f2) == typeof(f)
            @test getdomain(f2) == getdomain(f)
            @test nameof(f2) == nameof(f)
        end

        @testset "Downsampling" begin
            if N == 3
                f_small = downsample(f, 150, 50, 50)
                @test size(f_small) == (150, 50, 50)
                f_small = downsample(f)
                @test all(size(f_small) .≤ 15)
            elseif N == 2
                f_small = downsample(f, 50, 50)
                @test size(f_small) == (50, 50)
                f_small = downsample(f)
                @test all(size(f_small) .≤ 25)
            else
                f_small = downsample(f, 5)
                @test size(f_small) == (5,)
            end
            @test nameof(f) == nameof(f_small) == "$(N)D"
        end

        @testset "Slicing" begin
            if N > 1
                f_slice = selectdim(f, :x, zero(recursive_bottom_eltype(grid)))
                @test length(propertynames(f_slice)) == N - 1
                @test dimensionality(f_slice) == N - 1
                @test nameof(f_slice) == nameof(f)
            end
        end

        @testset "LinearAlgebra" begin
            nvf = norm.(f)
            @test scalarness(typeof(nvf)) === ScalarQuantity()
            @test norm.(f)[2] == nvf[2]
            # When converting to scalars from vectors we drop the name
            @test nameof(nvf) == ""

            if N == 3
                c = f × f
                @test all(iszero.(c))
                nameof(c) == "3D × 3D"
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

        @test ustrip(u"V/m", fields[4]) == fields[1]
        @test ustrip(u"V/m", fields[5]) == fields[2]
        @test ustrip(u"V/m", fields[6]) == fields[3]

        @test ustrip(u"V/m", u"m", fields[4]) == fields[1]
        @test ustrip(u"V/m", u"m", fields[5]) == fields[2]
        @test ustrip(u"V/m", u"m", fields[6]) == fields[3]


        @test ustrip(fields[1]) == fields[1]
        @test nameof(ustrip(fields[1])) == "1D"
        @test nameof(ustrip(u"V/m", fields[4])) == "1D"
        @test nameof(ustrip(u"V/m", u"m", fields[4])) == "1D"
    end
end

@testset "Vector variable interface" begin
    grids = [
        ParticlePositions(sin.(0:0.1:2π)),
        ParticlePositions(sin.(0:0.1:2π),cos.(0:0.1:2π)),
        ParticlePositions(sin.(0:0.1:2π),cos.(0:0.1:2π),sin.(0:0.1:2π)),
        ParticlePositions(sin.(0:0.1:2π).*u"m"),
        ParticlePositions(sin.(0:0.1:2π).*u"m",cos.(0:0.1:2π).*u"m"),
        ParticlePositions(sin.(0:0.1:2π).*u"m",cos.(0:0.1:2π).*u"m",sin.(0:0.1:2π).*u"m"),
    ]
    scalar_vars = [
        scalarvariable(grids[1]) do (x,)
            x^2
        end,
        scalarvariable(grids[2]) do (x,y)
            (x)/10
        end,
        scalarvariable(grids[3]) do (x,y,z)
            (x^2 + y^2 + z^2)/10
        end,
        scalarvariable(grids[4]) do (x,)
            x^2
        end,
        scalarvariable(grids[5]) do (x,y)
            (x)/10
        end,
        scalarvariable(grids[6]) do (x,y,z)
            (x^2 + y^2 + z^2)/10
        end,
    ]
    vars = [
        build_vector((scalar_vars[1], ), (:x,), name="1D"),
        build_vector((scalar_vars[2], scalar_vars[2]), (:x, :y), name="2D"),
        build_vector((scalar_vars[3], scalar_vars[3], scalar_vars[3]), (:x, :y, :z), name="3D"),
        build_vector((scalar_vars[4], ), (:x,), name="1D"),
        build_vector((scalar_vars[5], scalar_vars[5]), (:x, :y), name="2D"),
        build_vector((scalar_vars[6], scalar_vars[6], scalar_vars[6]), (:x, :y, :z), name="3D")
    ]

    @testset "$(dimensionality(v))D ($(unitname(v)))" for (grid,f,v) in zip(grids,scalar_vars,vars)
        @test v isa VectorVariable
        @test getdomain(v) == getdomain(f) == grid

        T = typeof(v)
        N = dimensionality(v)
        @test isconcretetype(T)

        @test v.x == f

        @testset "Traits" begin
            @test scalarness(T) === VectorQuantity()
            @test domain_discretization(T) === ParticleGrid()
            @test domain_type(T) <: ParticlePositions
        end

        @testset "Indexing" begin
            @test size(v) == size(grid)
            @test v[1] isa SVector
            @test v[1,:] == getfield(v, :data)[1,:]
        end

        @testset "Broadcasting" begin
            bc = Base.broadcasted(x->x*2, v)
            ibc = Base.Broadcast.instantiate(bc)
            ElType = Base.Broadcast.combine_eltypes(ibc.f, ibc.args)
            @test ElType == eltype(v)

            v2 = v .* 2
            @test v .* 1 == v
            @test typeof(v2) == typeof(v)
            @test getdomain(v2) == getdomain(v)
            @test nameof(v2) == nameof(v)
        end

        @testset "Downsampling" begin
            v_small = downsample(v, 5)
            @test size(v_small) == (5,)
            v_small = downsample(v)
            @test all(size(v_small) .≤ size(v))
            @test nameof(v) == nameof(v_small)
        end

        @testset "LinearAlgebra" begin
            nvf = norm.(v)
            @test scalarness(typeof(nvf)) === ScalarQuantity()
            @test norm.(v)[2] == nvf[2]
            # When converting to scalars from vectors we drop the name
            @test nameof(nvf) == ""

            if N == 3
                c = v × v
                @test all(iszero.(c))
                nameof(c) == "3D × 3D"
            end
        end
    end

    @testset "Sclicing" begin
        @testset "2D" begin
            v = vars[2]
            v_slice = selectdim(v, :x, 0.0, ϵ=0.1)
            @test dimensionality(v_slice) == 1
            @test propertynames(v_slice) == (:y,)
            @test size(v_slice) == size(getdomain(v_slice))
            @test length(v_slice) == 5
            @test all(isapprox.(only.(v_slice), 0.0, atol=1e-2))
            @test propertynames(getdomain(v_slice)) == (:y,)
            # TODO: make this less fragile
            @test all(isapprox.(getdomain(v_slice).y[[1,2,5]], 1.0, atol=1e-2))
            @test all(isapprox.(getdomain(v_slice).y[3:4], -1.0, atol=1e-2))

            @test nameof(v) == nameof(v_slice) == "2D"
        end
        @testset "3D" begin
            v = vars[3]
            v_slice = selectdim(v, :x, 0.0, ϵ=0.1)
            @test dimensionality(v_slice) == 2
            @test propertynames(v_slice) == (:y,:z)
            @test size(v_slice) == size(getdomain(v_slice))
            @test length(v_slice) == 5
            @test all(isapprox.(v_slice, ([0.1, 0.1],), atol=1e-2))
            @test propertynames(getdomain(v_slice)) == (:y,:z)
            # TODO: make this less fragile
            @test all(isapprox.(getdomain(v_slice).y[[1,2,5]], 1.0, atol=1e-2))
            @test all(isapprox.(getdomain(v_slice).y[3:4], -1.0, atol=1e-2))
            @test count(getdomain(v_slice).z .< 0.0) == 2
            @test iszero(first(getdomain(v_slice).z))

            @test nameof(v) == nameof(v_slice) == "3D"
        end
    end

    @testset "Units" begin
        @test ustrip(vars[4]) == vars[1]
        @test vars[1] .* 1u"m^2" == vars[4]

        @test ustrip(vars[5]) == vars[2]
        @test vars[2] .* 1u"m" == vars[5]

        @test ustrip(vars[6]) == vars[3]
        @test vars[3] .* 1u"m^2" == vars[6]

        @test nameof(ustrip(vars[1])) == "1D"
    end
end
