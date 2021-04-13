using PICDataStructures
using Test, SafeTestsets

@testset "PICDataStructures.jl" begin
    @safetestset "Generic tests" begin include("generic.jl") end
    @safetestset "Scalar quantities" begin include("scalar.jl") end
    @safetestset "Vector quantities" begin include("vector.jl") end
end
