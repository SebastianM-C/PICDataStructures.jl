# Version v0.4

## Breaking changes:
- `norm(f::AbstractPICDataStructure)` has been removed in favour of `norm.(f)`, as the latter is now possible and faster
- `dropdims(grid::AbstractGrid, dim)` has been replaced withs `dropdims(grid::AbstractGrid; dims)`

## New features:
- Broadcasting is now specialized for saclars and vectors via the `scalarness` trait. It is now possible to construct scalars form vectors in broadcasting, which removes the need for specialized functions such as `norm`
- Specialization of the cross product of vectors which improves the performance over the broadcasted version
- `arrows` recipe for Makie
- `mapgrid(f, grid)` maps a function to grid points
- `scalarfield(f, grid)` creates a scalar field on the `grid` with the values given by `f`
- `slice` for vector fields
- `selectdims` now is specialized on `AbstractPICDataStructure`s and returns a `AbstractPICDataStructure`
