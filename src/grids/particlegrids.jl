struct ParticlePositions{N,T,V<:AbstractVector{T},Names} <: AbstractGrid{N,T,Names}
    grid::NamedTuple{Names,NTuple{N,V}}
    minvals::MVector{N,T}
    maxvals::MVector{N,T}
end

function ParticlePositions(args::Vararg{T,N}; names=:auto, mins=:auto, maxs=:auto) where {N, T<:AbstractVector}
    names = replace_default_names(names, N)
    grid = NamedTuple{names}(args)

    mins = mins == :auto ? MVector(map(minimum, args)) : mins
    maxs = maxs == :auto ? MVector(map(maximum, args)) : maxs

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
    mins = minimum(grid)
    maxs = maximum(grid)
    mins .= 0
    maxs .= 0

    return grid
end

function Base.empty(::ParticlePositions{N,T}) where {N,T}
    ParticlePositions((T[],), mins=zero(MVector{N}), maxs=zero(MVector{N}))
end

function Base.append!(grid::ParticlePositions, new_grid::ParticlePositions)
    for (grid_dir, new_g) in zip(grid, new_grid)
        append!(grid_dir, new_g)
    end
    mins = minimum(grid)
    maxs = maximum(grid)
    new_mins = minimum(new_grid)
    new_maxs = maximum(new_grid)
    for (m,nm) in zip(mins, new_mins)
        if nm > m
            m = nm
        end
    end
    for (m,nm) in zip(maxs, new_maxs)
        if nm > m
            m = nm
        end
    end

    return grid
end

# This makes size(field) == size(grid)
Base.size(g::ParticlePositions) = (length(first(g)), )

Base.minimum(g::ParticlePositions) = getfield(g, :minvals)
Base.maximum(g::ParticlePositions) = getfield(g, :maxvals)

Base.sort(g::ParticlePositions, dir) = ParticlePositions(sort(getproperty(g, dir)), g.minvals, g.maxvals)

function Base.sort!(f::T, dim) where T <: AbstractPICDataStructure
    sort!(domain_discretization(T), f, dim)
end

function Base.sort!(::ParticleGrid, f, dir)
    grid = getdomain(f)
    sort_idx = sortperm(getproperty(grid, dim))
    permute!.(grid, (sort_idx,))
    permute!(unwrapdata(f), sort_idx)

    return f
end
