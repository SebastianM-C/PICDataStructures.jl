# Version v0.4.1

## New features
- Vector fields can now be also constructed form `AbstractArray`s of `SVector`s of the components.
- The components for vector quantities accesible by `getproperty` are now scalars as oposed to the underlying unwrapped data.
- Export `unitname`. This function gives the name of the units for the input.

## Bug fixes
- `dropdims` for `VectorQuantity` now correctly dorps the given `dims` from the grid.
# Version v0.4

## Breaking changes
- `norm(f::AbstractPICDataStructure)` has been removed in favour of `norm.(f)`, as the latter is now possible and faster
- `dropdims(grid::AbstractGrid, dim)` has been replaced withs `dropdims(grid::AbstractGrid; dims)`

## New features
- Refactor plot recipes. With this change the basic type recipes are based on traits
like `SurfaceLike` or `VolumeLike` which make almost everyhing plottable
with the default functions such as `contour`, `heatmap` or `volume`.
More specialized recipes create new plotting functions and establish
some defaults which heiristically give good looking plots.
- Broadcasting is now specialized for saclars and vectors via the `scalarness` trait. It is now possible to construct scalars form vectors in broadcasting, which removes the need for specialized functions such as `norm`
- Specialization of the cross product of vectors which improves the performance over the broadcasted version
- `arrows` recipe for Makie
- `mapgrid(f, grid)` maps a function to grid points
- `scalarfield(f, grid)` creates a scalar field on the `grid` with the values given by `f`
- `slice` for vector fields
- `selectdims` now is specialized on `AbstractPICDataStructure`s and returns a `AbstractPICDataStructure`
- `hasunits` indicates whether the input has units
- `AbstractPICDataStructure` now has a grid type parameter
