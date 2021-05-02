function dir_to_idx(dir::Symbol)
    if dir === :x
        1
    elseif dir === :y
        2
    elseif dir === :z
        3
    else
        0
    end
end

dir_to_idx(i::Int) = i

getdomain(g::AbstractGrid) = getfield(g, :grid)
getdomain(f::AbstractPICDataStructure) = getfield(f, :grid)
unwrapdata(f::AbstractPICDataStructure) = getfield(f, :data)

"""
    axisnames(f::AbstractPICDataStructure; include_units=true)

Get the names of the axis of the grid corresponding to the input data structure `f`.
In the case of Unitful quantities, they can be excluded by setting `include_units` to `false`.
"""
axisnames(f::AbstractPICDataStructure; include_units=true) = axisnames(getdomain(f); include_units)

function unwrap(f)
    _f = hasunits(f) ? ustrip(f) : f

    grid = getdomain(_f)
    data = unwrapdata(_f)

    return grid, data
end

function unwrap(f::Observable)
    # @debug "unwraping Observable"
    _f = @lift hasunits($f) ? ustrip($f) : $f

    dirs = propertynames(getdomain(f[]))
    grid = map(dirs) do dir
        lift(_f) do val_f
            g = getdomain(val_f)
            getproperty(g, dir)
        end
    end
    data = @lift Float32.(unwrapdata($_f))

    return grid, data
end

dimensionality(::AbstractGrid{N}) where N = N
dimensionality(::Type{<:AbstractGrid{N}}) where N = N
dimensionality(::AbstractPICDataStructure{T,N,G}) where {T,N,G} = dimensionality(G)
dimensionality(::Type{<:AbstractPICDataStructure{T,N,G}}) where {T,N,G} = dimensionality(G)

function mapgrid(f, grid::AbstractAxisGrid)
    map(f, Iterators.product(grid...))
end

function mapgrid(f, grid::ParticlePositions)
    map(f, zip(grid...))
end

mapgrid(f, field::AbstractPICDataStructure) = mapgrid(f, getdomain(field))

function scalarfield(f, grid)
    data = mapgrid(f, grid)
    ScalarField(data, grid)
end

function scalarvariable(f, grid)
    data = mapgrid(f, grid)
    ScalarVariable(data, grid)
end

function vectorfield(f, grid)
    data = mapgrid(f, grid)
    VectorField(data, grid, (:x,:y,:z))
end
