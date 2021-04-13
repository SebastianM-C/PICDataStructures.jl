module PICDataStructures

export AbstractPICDataStructure,
    ScalarField, ScalarVariable, VectorField, VectorVariable,
    AbstractGrid, AbstractAxisGrid, AxisGrid, SparseAxisGrid, ParticlePositions,
    build_vector, getdomain, mapgrid, scalarfield, scalarvariable,
    downsample, slice,
    scalarness, domain_type, domain_discretization,
    ScalarQuantity, VectorQuantity, LatticeGrid, ParticleGrid

using LinearAlgebra
using CoordinateTransformations
using ImageTransformations
using StaticArrays
using StructArrays
using RecursiveArrayTools
using IntervalSets
using ArrayInterface: parameterless_type
using Unitful
using Unitful: Units
using AbstractPlotting
import RecipesBase, UnitfulRecipes

abstract type AbstractPICDataStructure{T,N} <: AbstractArray{T,N} end

include("abstractarray.jl")
include("grids.jl")
include("scalar.jl")
include("vector.jl")
include("traits.jl")
include("units.jl")
include("algebra.jl")
include("transformations.jl")
include("subset.jl")
include("recipes/abstractplotting.jl")
include("recipes/recipesbase.jl")
include("utils.jl")
include("show.jl")

end # module PICDataStructures
