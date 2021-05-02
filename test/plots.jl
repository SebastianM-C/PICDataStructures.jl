using PICDataStructures, Test
using PICDataStructures: dimensionality
using Unitful
using CairoMakie

@testset "Scalar fields" begin
    grids =
        SparseAxisGrid(0.01:0.1:1),
        SparseAxisGrid(-1:0.012:1, -1:0.012:1),
        SparseAxisGrid(-1:0.0052:1, -1:0.012:1, -1:0.012:1),
        SparseAxisGrid(0.01u"m":0.1u"m":1.0u"m"),
        SparseAxisGrid(-1u"m":0.012u"m":1u"m", -1u"m":0.012u"m":1u"m"),
        SparseAxisGrid(-1u"m":0.0052u"m":1u"m", -1u"m":0.012u"m":1u"m", -1u"m":0.012u"m":1u"m")

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

    @testset "Unitless" begin
        f = fields[1]
        fig = plotdata(f)
        @test fig.current_axis[].xlabel[] == "x"

        f = fields[2]
        fig = plotdata(f)
        @test fig.current_axis[].xlabel[] == "x"
        @test fig.current_axis[].ylabel[] == "y"

        f = fields[3]
        fig = plotdata(f)
        @test fig.current_axis[].scene[OldAxis][:names, :axisnames][] == ("x", "y", "z")
    end

    @testset "Unitful" begin
        f = fields[4]
        fig = plotdata(f)
        u = unitname(getdomain(f))
        @test u == "m"
        @test fig.current_axis[].xlabel[] == "x ($u)"

        f = fields[5]
        fig = plotdata(f)
        u = unitname(getdomain(f))
        @test fig.current_axis[].xlabel[] == "x ($u)"
        @test fig.current_axis[].ylabel[] == "y ($u)"

        f = fields[6]
        fig = plotdata(f)
        u = unitname(getdomain(f))
        # VolumeLike doesn't work on CairoMakie
        @test_broken fig.current_axis[].scene[OldAxis][:names, :axisnames][] == ("x ($u)", "y ($u)", "z ($u)")
    end
end

@testset "Scalar variables" begin
    grids = [
        ParticlePositions(sin.(0:0.1:2π)),
        ParticlePositions(sin.(0:0.1:2π),cos.(0:0.1:2π)),
        ParticlePositions(sin.(0:0.1:2π),cos.(0:0.1:2π),sin.(0:0.1:2π)),
        ParticlePositions(sin.(0:0.1:2π).*u"m"),
        ParticlePositions(sin.(0:0.1:2π).*u"m",cos.(0:0.1:2π).*u"m"),
        ParticlePositions(sin.(0:0.1:2π).*u"m",cos.(0:0.1:2π).*u"m",sin.(0:0.1:2π).*u"m"),
    ]
    vars = [
        scalarvariable(grids[1]) do (x,)
            x^2
        end,
        scalarvariable(grids[2]) do (x,y)
            x^2 + y^2
        end,
        scalarvariable(grids[3]) do (x,y,z)
            (x^2 + y^2 + z^2)
        end,
        scalarvariable(grids[4]) do (x,)
            x^2
        end,
        scalarvariable(grids[5]) do (x,y)
            (x^2 + y^2)
        end,
        scalarvariable(grids[6]) do (x,y,z)
            (x^2 + y^2 + z^2)
        end,
    ]

    @testset "Unitless" begin
        v = vars[1]
        fig = plotdata(v)
        @test fig.current_axis[].xlabel[] == "x"

        v = vars[2]
        fig = plotdata(v)
        @test fig.current_axis[].xlabel[] == "x"
        @test fig.current_axis[].ylabel[] == "y"
        @test all(fig.content[2].limits[] .≈ (-1,1))

        v = vars[3]
        fig = plotdata(v)
        @test fig.current_axis[].scene[OldAxis][:names, :axisnames][] == ("x", "y", "z")
    end

    @testset "Unitful" begin
        v = vars[4]
        fig = plotdata(v)
        u = unitname(getdomain(v))
        @test u == "m"
        @test fig.current_axis[].xlabel[] == "x ($u)"

        v = vars[5]
        fig = plotdata(v)
        u = unitname(getdomain(v))
        @test u == "m"
        @test fig.current_axis[].xlabel[] == "x ($u)"
        @test fig.current_axis[].ylabel[] == "y ($u)"
        @test all(fig.content[2].limits[] .≈ (-1,1))

        v = vars[6]
        fig = plotdata(v)
        @test_broken fig.current_axis[].scene[OldAxis][:names, :axisnames][] == ("x ($u)", "y ($u)", "z ($u)")
    end
end

@testset "Vector fields" begin
    grids =
        SparseAxisGrid(0.01:0.1:1),
        SparseAxisGrid(-1:0.012:1, -1:0.012:1),
        SparseAxisGrid(-1:0.0052:1, -1:0.012:1, -1:0.012:1),
        SparseAxisGrid(0.01u"m":0.1u"m":1.0u"m"),
        SparseAxisGrid(-1u"m":0.012u"m":1u"m", -1u"m":0.012u"m":1u"m"),
        SparseAxisGrid(-1u"m":0.0052u"m":1u"m", -1u"m":0.012u"m":1u"m", -1u"m":0.012u"m":1u"m")

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
        build_vector((scalar_fields[1], ), (:x,)),
        build_vector((scalar_fields[2], scalar_fields[2]), (:x, :y)),
        build_vector((scalar_fields[3], scalar_fields[3], scalar_fields[3]), (:x, :y, :z)),
        build_vector((scalar_fields[4], ), (:x,)),
        build_vector((scalar_fields[5], scalar_fields[5]), (:x, :y)),
        build_vector((scalar_fields[6], scalar_fields[6], scalar_fields[6]), (:x, :y, :z))
    ]

    @testset "Unitless" begin
        # Does 1D make sense?
        # f = fields[1]
        # fig = plotdata(f)
        # @test fig.current_axis[].xlabel[] == "x"

        f = fields[2]
        fig = plotdata(f)
        @test fig.current_axis[].xlabel[] == "x"
        @test fig.current_axis[].ylabel[] == "y"

        f = fields[3]
        fig = plotdata(f)
        @test fig.current_axis[].scene[OldAxis][:names, :axisnames][] == ("x", "y", "z")
    end

    @testset "Unitful" begin
        # f = fields[4]
        # fig = plotdata(f)
        # u = unitname(getdomain(f))
        # @test u == "m"
        # @test fig.current_axis[].xlabel[] == "x ($u)"

        f = fields[5]
        fig = plotdata(f)
        u = unitname(getdomain(f))
        @test fig.current_axis[].xlabel[] == "x ($u)"
        @test fig.current_axis[].ylabel[] == "y ($u)"

        f = fields[6]
        fig = plotdata(f)
        u = unitname(getdomain(f))
        # VolumeLike doesn't work on CairoMakie
        @test_broken fig.current_axis[].scene[OldAxis][:names, :axisnames][] == ("x ($u)", "y ($u)", "z ($u)")
    end
end
