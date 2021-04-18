for f in (:minimum, :maximum)
    @eval begin
        function (Base.$f)(grid::AbstractAxisGrid{N}) where N
            ntuple(N) do i
                $f(grid.grid[i])
            end
        end
    end
end

Base.minimum(g::ParticlePositions) = g.minvals
Base.maximum(g::ParticlePositions) = g.maxvals

Base.sort(g::ParticlePositions, dim) = ParticlePositions(sort(g[dim]), g.minvals, g.maxvals)

function Base.sort!(f::T, dim) where T <: AbstractPICDataStructure
    sort!(domain_discretization(T), f, dim)
end

function Base.sort!(::ParticleGrid, f, dim)
    grid = getdomain(f)
    sort_idx = sortperm(grid[dim])
    permute!.(grid, (sort_idx,))
    permute!(unwrapdata(f), sort_idx)

    return f
end

getdomain(f::AbstractPICDataStructure) = getfield(f, :grid)
unwrapdata(f::AbstractPICDataStructure) = getfield(f, :data)

Base.dropdims(f::T; dims) where T <: AbstractPICDataStructure = dropdims(scalarness(T), f; dims)

function Base.dropdims(::VectorQuantity, f; dims)
    selected_dims = filter(c->c≠dims, propertynames(f))
    data = unwrapdata(f)
    grid = getdomain(f)

    selected_data = StructArray(component.((data,), selected_dims), names=selected_dims)

    parameterless_type(f)(selected_data, grid)
end

function broadcast_grid(f, g::NTuple{N}) where N
    ntuple(N) do i
        f.(g[i])
    end
end

function broadcast_grid(f, arg, g::NTuple{N}) where N
    ntuple(N) do i
        f.(arg, g[i])
    end
end

function unwrap(f)
    _f = hasunits(f) ? ustrip(f) : f

    grid = getdomain(_f)
    data = unwrapdata(_f)

    return grid, data
end

function unwrap(f::Observable)
    _f = @lift hasunits($f) ? ustrip($f) : $f

    N = dimensionality(_f[])
    grid = ntuple(N) do i
        lift(_f) do val_f
            getdomain(val_f)[i]
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
