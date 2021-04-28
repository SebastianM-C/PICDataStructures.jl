struct ParticlePositions{N,T,V<:AbstractVector{T},Names} <: AbstractGrid{N,T,Names}
    grid::NamedTuple{Names,NTuple{N,V}}
    minvals::MVector{N,T}
    maxvals::MVector{N,T}
end

function ParticlePositions(args::Vararg{T,N}; names=:auto) where {N, T<:AbstractVector}
    names = replace_default_names(names, N)
    grid = NamedTuple{names}(args)

    mins = MVector(map(minimum, args))
    maxs = MVector(map(maximum, args))

    ParticlePositions(grid, mins, maxs)
end

function ParticlePositions{N,T}() where {N,T}
    grid = ntuple(N) do i
        T[]
    end
    mins = zero(MVector{N,T})
    maxs = zero(MVector{N,T})

    ParticlePositions(grid, mins, maxs)
end

# This makes size(field) == size(grid)
# Base.size(g::ParticlePositions) = map(length, values(getdomain(g)))

@propagate_inbounds function Base.getindex(grid::ParticlePositions{N}, idxs::Vector{Int}) where N
    g = ntuple(N) do i
        grid[i][idxs]
    end
    ParticlePositions(g)
end

function Base.empty!(grid::ParticlePositions{N,T}) where {N,T}
    for grid_dir in grid
        empty!(grid_dir)
    end
    grid.minvals .= 0
    grid.maxvals .= 0

    return grid
end

function Base.empty(::ParticlePositions{N,T}) where {N,T}
    ParticlePositions((T[],), zero(MVector{N}), zero(MVector{N}))
end

function Base.append!(grid::ParticlePositions, new_grid::ParticlePositions)
    for (grid_dir, new_g) in zip(grid, new_grid)
        append!(grid_dir, new_g)
    end
    grid.minvals .= new_grid.minvals
    grid.maxvals .= new_grid.maxvals

    return grid
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
