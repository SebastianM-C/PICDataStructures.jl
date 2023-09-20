module PICDataStructures

export AbstractPICDataStructure,
    ScalarField, ScalarVariable, VectorField, VectorVariable,
    AbstractGrid, AbstractAxisGrid, AxisGrid, SparseAxisGrid, ParticlePositions,
    build_vector, getdomain, mapgrid, axisnames,
    scalarfield, scalarvariable, vectorfield,
    hasunit, unitname,
    downsample,
    scalarness, domain_type, domain_discretization,
    ScalarQuantity, VectorQuantity, LatticeGrid, ParticleGrid,
    plotdata

# Arrays
using StaticArrays
using StructArrays
using RecursiveArrayTools
using BangBang
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
# Track what remains to be moved over to MakieCore
using Makie: @lift, lift, Arrows, Contour, Hist,
    Figure, Colorbar, Axis,
    AxisAspect, DataAspect, replace_automatic!,
    Point, Vec, LScene, SceneSpace,
    arrows!, contour!,
    cam3d!
using Observables
using MakieCore
using MakieCore: convert_arguments, @recipe, theme, Attributes,
    automatic,
    PointBased, DiscreteSurface, ContinuousSurface, VolumeLike
import RecipesBase

abstract type AbstractPICDataStructure{T,N,G} <: AbstractArray{T,N} end

include("abstractarray.jl")
include("grids/grids.jl")
include("scalar.jl")
include("vector.jl")
include("traits.jl")
include("units.jl")
include("algebra.jl")
# include("transformations.jl")
include("subset/subset.jl")
include("recipes/plot.jl")
include("recipes/recipesbase.jl")
include("utils.jl")
include("show.jl")

end # module PICDataStructures
