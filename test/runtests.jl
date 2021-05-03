using PICDataStructures
using Test, SafeTestsets

@testset "PICDataStructures.jl" begin
    @safetestset "Code quality" begin include("quality.jl") end
    @safetestset "Grids" begin include("grids.jl") end
    @safetestset "Scalar quantities" begin include("scalar.jl") end
    @safetestset "Vector quantities" begin include("vector.jl") end
    @safetestset "Plotting" begin include("plots.jl") end
end
