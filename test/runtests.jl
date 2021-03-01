using PICDataStructures
using Test, SafeTestsets

@testset "PICDataStructures.jl" begin
    @safetestset "Scalar quantities" begin include("scalar.jl") end
    @safetestset "Vector quantities" begin include("scalar.jl") end
end
