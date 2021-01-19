using PICDataStructures
using Test, SafeTestsets

@testset "PICDataStructures.jl" begin
    @safetestset "Scalar fields" begin include("scalar.jl") end
end
