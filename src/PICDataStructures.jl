module PICDataStructures

export AbstractPICDataStructure,
    ScalarField, ScalarVariable, VectorField, VectorVariable,
    subsample, slice,
    scalarness, domain_type, domain_discretization,
    ScalarQuantity, VectorQuantity, LatticeGrid, ParticleGrid

using LinearAlgebra
using CoordinateTransformations
using ImageTransformations
using StaticArrays
using RecursiveArrayTools
using IntervalSets
using ArrayInterface: parameterless_type
using Unitful
using Unitful: Units
using AbstractPlotting

abstract type AbstractPICDataStructure{T,N} <: AbstractArray{T,N} end

include("scalar.jl")
include("vector.jl")
include("traits.jl")
include("units.jl")
include("algebra.jl")
include("transformations.jl")
include("subset.jl")
include("recipes.jl")

# Indexing
Base.@propagate_inbounds Base.getindex(f::AbstractPICDataStructure, i::Int) = f.data[i]
Base.@propagate_inbounds Base.setindex!(f::AbstractPICDataStructure, v, i::Int) = f.data[i] = v

Base.firstindex(f::AbstractPICDataStructure) = firstindex(f.data)
Base.lastindex(f::AbstractPICDataStructure) = lastindex(f.data)

Base.size(f::AbstractPICDataStructure, dim...) = size(f.data, dim...)

Base.LinearIndices(f::AbstractPICDataStructure) = LinearIndices(f.data)
Base.IndexStyle(::Type{<:AbstractPICDataStructure}) = Base.IndexLinear()

# Iteration
Base.iterate(f::AbstractPICDataStructure, state...) = iterate(f.data, state...)
Base.length(f::AbstractPICDataStructure) = length(f.data)

# Broadcasting
Base.BroadcastStyle(::Type{<:AbstractPICDataStructure}) = Broadcast.ArrayStyle{AbstractPICDataStructure}()

function Base.similar(f::AbstractPICDataStructure, ::Type{S}, dims::Dims) where S
    parameterless_type(f)(similar(f.data, S, dims), f.grid)
end

function Base.copyto!(dest::AbstractPICDataStructure, src::AbstractPICDataStructure)
    copyto!(dest.data, src.data)

    return dest
end

function Base.similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{AbstractPICDataStructure}}, ::Type{ElType}) where ElType
    # Scan the inputs for the AbstractPICDataStructure:
    f = find_field(bc)
    grid = f.grid
    # Keep the same grid for the output
    parameterless_type(f)(similar(f.data, ElType, axes(bc)), grid)
end

"""
`A = find_filed(Fs)` returns the first `AbstractPICDataStructure` among the arguments.
"""
find_field(bc::Base.Broadcast.Broadcasted) = find_field(bc.args)
find_field(args::Tuple) = find_field(find_field(first(args)), Base.tail(args))
find_field(f) = f
find_field(::Tuple{}) = nothing
find_field(f::AbstractPICDataStructure, rest) = f
find_field(::Any, rest) = find_field(rest)

# Custom pretty-printing

Base.show(io::IO, ::MIME"text/plain", ::ScalarQuantity) = print(io, "Scalar")
Base.show(io::IO, ::MIME"text/plain", ::VectorQuantity) = print(io, "Vector")

function Base.show(io::IO, m::MIME"text/plain", f::AbstractPICDataStructure)
    show(io, m, scalarness(typeof(f)))
    data_units = unit(recursive_bottom_eltype(f.data))
    grid_units = unit(recursive_bottom_eltype(f.grid))
    print(io, " with data in " * string(data_units) * ": \n")
    ctx = IOContext(io, :limit=>true, :compact=>true, :displaysize => (10,50))
    Base.print_array(ctx, f.data)
    print(io, "\nand grid in " * string(grid_units) * ": ")
    print(io, f.grid)
end

end # module PICDataStructures