using PICDataStructures, Test

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

        @testset "dropdims" begin
            grid = SparseAxisGrid(1:10, 1:11, 1:12)
            grid2 = dropdims(grid, dims=:z)

            @test dimensionality(grid2) == dimensionality(grid) - 1
            @test propertynames(grid2) == (:x, :y)
            @test grid2.x == grid.x == 1:10
            @test grid2.y == grid.y == 1:11

            grid1 = dropdims(grid, dims=(:x,:y))
            @test dimensionality(grid1) == dimensionality(grid) - 2
            @test propertynames(grid1) == (:x,)
            @test grid1.z == grid.z == 1:12
        end

        @testset "Units" begin
            grid = SparseAxisGrid(1u"m":10u"m", 1u"m":10u"m")
            unitless_grid = SparseAxisGrid(1:10, 1:10, 1:10)

            @test ustrip(grid) == unitless_grid
            @test ustrip(u"mm", grid).x[1] == 1000
        end
    end

    @testset "AxisGrid" begin
        grid = AxisGrid(collect(1:10))
        @test propertynames(grid) == (:x,)
        @test grid.x == collect(1:10)

        grid = AxisGrid(collect(1:10), collect(1:10))
        @test propertynames(grid) == (:x,:y)
        @test grid.x == collect(1:10)
        @test grid.y == collect(1:10)

        grid = AxisGrid(collect(1:10), collect(1:10), collect(1:10))
        @test propertynames(grid) == (:x,:y,:z)
        @test grid.x == collect(1:10)
        @test grid.y == collect(1:10)
        @test grid.z == collect(1:10)

        grid = AxisGrid(collect(1:10), collect(1:10), collect(1:10), collect(1:10))
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
end

@testset "ParticleGrid" begin
    @testset "ParticlePositions" begin
        grid = ParticlePositions(collect(1:10))
        @test propertynames(grid) == (:x,)
        @test grid.x == collect(1:10)

        grid = ParticlePositions(collect(1:10), collect(1:10))
        @test propertynames(grid) == (:x,:y)
        @test grid.x == collect(1:10)
        @test grid.y == collect(1:10)

        grid = ParticlePositions(collect(1:10), collect(1:10), collect(1:10))
        @test propertynames(grid) == (:x,:y,:z)
        @test grid.x == collect(1:10)
        @test grid.y == collect(1:10)
        @test grid.z == collect(1:10)

        grid = ParticlePositions(collect(1:10), collect(1:10), collect(1:10), collect(1:10))
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
end
