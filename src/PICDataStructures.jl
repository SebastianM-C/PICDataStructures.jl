module PICDataStructures

export AbstractPICDataStructure,
    ScalarField, ScalarVariable, VectorField, VectorVariable,
    AbstractGrid, AbstractAxisGrid, AxisGrid, SparseAxisGrid, ParticlePositions,
    build_vector, getdomain, mapgrid,
    scalarfield, scalarvariable, vectorfield,
    hasunits, unitname,
    downsample,
    scalarness, domain_type, domain_discretization,
    ScalarQuantity, VectorQuantity, LatticeGrid, ParticleGrid

# Arrays
using StaticArrays
using StructArrays
using RecursiveArrayTools
using ArrayInterface: parameterless_type
using StructArrays: components, component, similar_structarray
using Base.Broadcast: Broadcasted, ArrayStyle
using Base: @propagate_inbounds
# Math
using LinearAlgebra
using CoordinateTransformations
using ImageTransformations
using IntervalSets
# Units
using Unitful
using Unitful: Units
# Plotting
using AbstractPlotting
using AbstractPlotting: PointBased, SurfaceLike, VolumeLike
import RecipesBase, UnitfulRecipes

abstract type AbstractPICDataStructure{T,N,G} <: AbstractArray{T,N} end

include("abstractarray.jl")
include("grids.jl")
include("scalar.jl")
include("vector.jl")
include("traits.jl")
include("units.jl")
include("algebra.jl")
include("transformations.jl")
include("subset/subset.jl")
include("recipes/abstractplotting.jl")
include("recipes/recipesbase.jl")
include("utils.jl")
include("show.jl")

end # module PICDataStructures
