using PICDataStructures, Test
using PICDataStructures: dimensionality
using Unitful

@testset "LatticeGrid" begin
    @testset "SparseAxisGrid" begin
        @testset "Construction" begin
            grid = SparseAxisGrid(1:10)
            @test propertynames(grid) == (:x,)
            @test grid.x == 1:10

            grid = SparseAxisGrid(1:10, 1:10)
            @test propertynames(grid) == (:x,:y)
            @test grid.x == 1:10
            @test grid.y == 1:10

            grid = SparseAxisGrid(1:10, 1:10, 1:10)
            @test propertynames(grid) == (:x,:y,:z)
            @test grid.x == 1:10
            @test grid.y == 1:10
            @test grid.z == 1:10

            grid = SparseAxisGrid(1:10, 1:10, 1:10, 1:10)
            @test propertynames(grid) == (:x1,:x2,:x3,:x4)
            @test grid.x1 == 1:10
            @test grid.x2 == 1:10
            @test grid.x3 == 1:10
            @test grid.x4 == 1:10

            grid = SparseAxisGrid(1.0:10, 0:2π, names=(:r, :θ))
            @test propertynames(grid) == (:r, :θ)
            @test grid.r == 1.0:10
            @test grid.θ == 0:2π
        end

        @testset "Essentials" begin
            grid = SparseAxisGrid(1:10, 1:10)

            @test eltype(grid) == Int
            @test length(grid) == 2
            @test size(grid) == (10,10)
            @test iterate(grid) == (grid.x, 2)
        end

        @testset "dropdims" begin
            grid = SparseAxisGrid(1:10, 1:11, 1:12)
            grid2 = dropdims(grid, dims=:z)

            @test dimensionality(grid2) == dimensionality(grid) - 1
            @test propertynames(grid2) == (:x, :y)
            @test grid2.x == grid.x == 1:10
            @test grid2.y == grid.y == 1:11

            grid = SparseAxisGrid(1:10, 1:11, 1:12)
            grid2 = dropdims(grid, dims=:y)

            @test dimensionality(grid2) == dimensionality(grid) - 1
            @test propertynames(grid2) == (:x, :z)
            @test grid2.x == grid.x == 1:10
            @test grid2.z == grid.z == 1:12

            grid1 = dropdims(grid, dims=(:x,:y))
            @test dimensionality(grid1) == dimensionality(grid) - 2
            @test propertynames(grid1) == (:z,)
            @test grid1.z == grid.z == 1:12
        end

        @testset "Units" begin
            grid = SparseAxisGrid(1u"m":1.0u"m":10u"m", 1u"m":0.5u"m":10u"m")
            unitless_grid = SparseAxisGrid(1:1.0:10, 1:0.5:10)

            u_grid = ustrip(grid)
            @test u_grid == unitless_grid
            @test ustrip(u"mm", grid).x[1] == 1000
            @test propertynames(u_grid) == propertynames(grid)

            grid = SparseAxisGrid(1u"m":2u"m":10u"m", 1u"m":2u"m":10u"m")
            unitless_grid = SparseAxisGrid(1:2:10, 1:2:10)

            u_grid = ustrip(grid)
            @test getdomain(u_grid) == getdomain(unitless_grid)
            @test ustrip(grid) == unitless_grid
            @test isequal(u_grid, unitless_grid)
            @test hash(u_grid) == hash(unitless_grid)
            @test ustrip(u"mm", grid).x[1] == 1000
            @test propertynames(u_grid) == propertynames(grid)
        end
    end

    @testset "AxisGrid" begin
        @testset "Construction" begin
            grid = AxisGrid(collect(1:10))
            @test propertynames(grid) == (:x,)
            @test grid.x == collect(1:10)

            grid = AxisGrid(collect.((1:10, 1:10))...)
            @test propertynames(grid) == (:x,:y)
            @test grid.x == collect(1:10)
            @test grid.y == collect(1:10)

            grid = AxisGrid(collect.((1:10, 1:10, 1:10))...)
            @test propertynames(grid) == (:x,:y,:z)
            @test grid.x == collect(1:10)
            @test grid.y == collect(1:10)
            @test grid.z == collect(1:10)

            grid = AxisGrid(collect.((1:10, 1:10, 1:10, 1:10))...)
            @test propertynames(grid) == (:x1,:x2,:x3,:x4)
            @test grid.x1 == collect(1:10)
            @test grid.x2 == collect(1:10)
            @test grid.x3 == collect(1:10)
            @test grid.x4 == collect(1:10)

            grid = AxisGrid(collect(1.0:10), collect(0:2π), names=(:r, :θ))
            @test propertynames(grid) == (:r, :θ)
            @test grid.r == collect(1.0:10)
            @test grid.θ == collect(0:2π)
        end

        @testset "Essentials" begin
            grid = AxisGrid(collect.((1:10, 1:10))...)

            @test eltype(grid) == Int
            @test length(grid) == 2
            @test size(grid) == (10,10)
            @test iterate(grid) == (grid.x, 2)
        end

        @testset "dropdims" begin
            grid = AxisGrid(collect.((1:10, 1:11, 1:12))...)
            grid2 = dropdims(grid, dims=:z)

            @test dimensionality(grid2) == dimensionality(grid) - 1
            @test propertynames(grid2) == (:x, :y)
            @test grid2.x == grid.x == collect(1:10)
            @test grid2.y == grid.y == collect(1:11)

            grid = AxisGrid(collect.((1:10, 1:11, 1:12))...)
            grid2 = dropdims(grid, dims=:y)

            @test dimensionality(grid2) == dimensionality(grid) - 1
            @test propertynames(grid2) == (:x, :z)
            @test grid2.x == grid.x == collect(1:10)
            @test grid2.z == grid.z == collect(1:12)

            grid1 = dropdims(grid, dims=(:x,:y))
            @test dimensionality(grid1) == dimensionality(grid) - 2
            @test propertynames(grid1) == (:z,)
            @test grid1.z == grid.z == collect(1:12)
        end

        @testset "Units" begin
            grid = AxisGrid(collect(1u"m":1u"m":10u"m"), collect(1u"m":1u"m":10u"m"))
            unitless_grid = AxisGrid(collect(1:10), collect(1:10))

            u_grid = ustrip(grid)
            @test getdomain(u_grid) == getdomain(unitless_grid)
            @test u_grid == unitless_grid
            @test isequal(u_grid, unitless_grid)
            @test hash(u_grid) == hash(unitless_grid)
            @test ustrip(u"mm", grid).x[1] == 1000
            @test propertynames(u_grid) == propertynames(grid)
        end
    end
end

@testset "ParticleGrid" begin
    @testset "ParticlePositions" begin
        @testset "Construction" begin
            grid = ParticlePositions(collect(1:10))
            @test propertynames(grid) == (:x,)
            @test grid.x == collect(1:10)

            grid = ParticlePositions(collect.((1:10, 1:10))...)
            @test propertynames(grid) == (:x,:y)
            @test grid.x == collect(1:10)
            @test grid.y == collect(1:10)

            grid = ParticlePositions(collect.((1:10, 1:10, 1:10))...)
            @test propertynames(grid) == (:x,:y,:z)
            @test grid.x == collect(1:10)
            @test grid.y == collect(1:10)
            @test grid.z == collect(1:10)

            grid = ParticlePositions(collect.((1:10, 1:10, 1:10, 1:10))...)
            @test propertynames(grid) == (:x1,:x2,:x3,:x4)
            @test grid.x1 == collect(1:10)
            @test grid.x2 == collect(1:10)
            @test grid.x3 == collect(1:10)
            @test grid.x4 == collect(1:10)

            grid = ParticlePositions(1.0:10, 0:2π, names=(:r, :θ))
            @test propertynames(grid) == (:r, :θ)
            @test grid.r == collect(1.0:10)
            @test grid.θ == collect(0:2π)
        end

        @testset "Essentials" begin
            grid = ParticlePositions(collect.((1:10, 1:10))...)

            @test eltype(grid) == Int
            @test length(grid) == 2
            @test size(grid) == (10,)
            @test iterate(grid) == (grid.x, 2)
        end

        @testset "dropdims" begin
            grid = ParticlePositions(collect.((1:10, 1:11, 1:12))...)
            grid2 = dropdims(grid, dims=:z)

            @test dimensionality(grid2) == dimensionality(grid) - 1
            @test propertynames(grid2) == (:x, :y)
            @test grid2.x == grid.x == collect(1:10)
            @test grid2.y == grid.y == collect(1:11)

            grid = ParticlePositions(collect.((1:10, 1:11, 1:12))...)
            grid2 = dropdims(grid, dims=:y)

            @test dimensionality(grid2) == dimensionality(grid) - 1
            @test propertynames(grid2) == (:x, :z)
            @test grid2.x == grid.x == collect(1:10)
            @test grid2.z == grid.z == collect(1:12)

            grid1 = dropdims(grid, dims=(:x,:y))
            @test dimensionality(grid1) == dimensionality(grid) - 2
            @test propertynames(grid1) == (:z,)
            @test grid1.z == grid.z == collect(1:12)
        end

        @testset "Units" begin
            grid = ParticlePositions(collect(1u"m":1u"m":10u"m"), collect(1u"m":1u"m":10u"m"))
            unitless_grid = ParticlePositions(collect(1:10), collect(1:10))

            u_grid = ustrip(grid)
            @test getdomain(u_grid) == getdomain(unitless_grid)
            @test u_grid == unitless_grid
            @test isequal(u_grid, unitless_grid)
            @test hash(u_grid) == hash(unitless_grid)
            @test ustrip(u"mm", grid).x[1] == 1000
            @test propertynames(u_grid) == propertynames(grid)
        end

        @testset "empty" begin
            grid = ParticlePositions(collect.((1:10, 1:10, 1:10))...)
            grid_copy = deepcopy(grid)

            ge = empty(grid)
            @test isempty(ge)
            @test empty!(grid_copy) == ge
            @test append!(grid_copy, grid) == grid
        end
    end
end

@testset "hash" begin
    axgrid = AxisGrid(collect.((1:10, 1:10))...)
    pgrid = ParticlePositions(collect.((1:10, 1:10))...)

    @test getdomain(axgrid) == getdomain(pgrid)
    # Ensure we have differernt hashes even if the contained data is the same
    @test axgrid ≠ pgrid
    @test hash(axgrid) ≠ hash(pgrid)

    # Check that the hash changes if we change the internal data
    h = hash(axgrid)
    axgrid.x[1] = 2
    @test hash(axgrid) ≠ h

    h = hash(pgrid)
    pgrid.x[1] = 2
    @test hash(pgrid) ≠ h
end
