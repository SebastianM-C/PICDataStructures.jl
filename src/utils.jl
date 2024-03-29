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

function newstruct(f::AbstractPICDataStructure, data, grid; name=:same)
    name = name == :same ? nameof(f) : name
    parameterless_type(f)(data, grid, name)
end

Base.nameof(f::AbstractPICDataStructure) = getfield(f, :name)

"""
    axisnames(f::AbstractPICDataStructure; include_units=true)

Get the names of the axis of the grid corresponding to the input data structure `f`.
In the case of Unitful quantities, they can be excluded by setting `include_units` to `false`.
"""
axisnames(f::AbstractPICDataStructure; include_units=true) = axisnames(getdomain(f); include_units)

function unwrap(f)
    _f = hasunit(f) ? ustrip(f) : f

    grid = getdomain(_f)
    data = unwrapdata(_f)

    return grid, data
end

expandgrid(f::Observable{T}) where T = expandgrid(domain_discretization(T), f)

function expandgrid(::LatticeGrid, f)
    dirs = propertynames(getdomain(f[]))
    map(dirs) do dir
        lift(f) do val_f
            g = getdomain(val_f)
            getproperty(g, dir)
        end
    end
end

function expandgrid(::ParticleGrid, f)
    @lift getdomain($f)
end

@inline function apply_reinterpret(f, data)
    T = recursive_unitless_bottom_eltype(data)
    data_units = recursive_bottom_unit(data)
    raw_data = reinterpret(T, data)
    resized_data = f(raw_data)
    U = typeof(one(T) * data_units)
    reinterpret(U, resized_data)
end

function unwrap(f::Observable)
    _f = @lift hasunit($f) ? ustrip($f) : $f

    grid = expandgrid(_f)
    data = @lift unwrapdata($_f)

    return grid, data
end

dimensionality(::AbstractGrid{N}) where N = N
dimensionality(::Type{<:AbstractGrid{N}}) where N = N
dimensionality(::AbstractPICDataStructure{T,N,G}) where {T,N,G} = dimensionality(G)
dimensionality(::Type{<:AbstractPICDataStructure{T,N,G}}) where {T,N,G} = dimensionality(G)
# use Tuple{T, Vararg{T,N}} since NTuple{N,T} can have N==0
dimensionality(::Type{<:NamedTuple{Names, Tuple{T, Vararg{T,N}}}}) where {Names, N, T} = N + 1

function mapgrid(f, grid::AbstractAxisGrid)
    map(f, Iterators.product(grid...))
end

function mapgrid(f, grid::ParticlePositions)
    map(f, zip(grid...))
end

mapgrid(f, field::AbstractPICDataStructure) = mapgrid(f, getdomain(field))

function scalarfield(f, grid; name="")
    data = mapgrid(f, grid)
    ScalarField(data, grid, name)
end

function scalarvariable(f, grid; name="")
    data = mapgrid(f, grid)
    ScalarVariable(data, grid, name)
end

function vectorfield(f, grid; name="")
    data = mapgrid(f, grid)
    VectorField(data, grid; name)
end
