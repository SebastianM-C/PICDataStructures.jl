abstract type AbstractGrid{N,T} end
abstract type AbstractAxisGrid{N,T} <: AbstractGrid{N,T} end

struct AxisGrid{N,T,V<:AbstractVector{T}} <: AbstractAxisGrid{N,T}
    grid::NTuple{N,V}
end

struct SparseAxisGrid{N,T,R<:AbstractRange{T}} <: AbstractAxisGrid{N,T}
    grid::NTuple{N,R}
end

struct ParticlePositions{N,T,V<:AbstractVector{T}} <: AbstractGrid{N,T}
    grid::NTuple{N,V}
    minvals::MVector{N,T}
    maxvals::MVector{N,T}
end

function ParticlePositions(grid)
    mins = MVector(map(minimum, grid))
    maxs = MVector(map(maximum, grid))

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

Base.eltype(g::AbstractGrid{N,T}) where {N,T} = eltype(g.grid)

Base.length(g::AbstractGrid) = length(g.grid)
Base.iterate(g::AbstractGrid, state...) = iterate(g.grid, state...)

# This makes size(field) == size(grid)
Base.size(g::AbstractGrid) = (length.(g.grid)...,)

Base.@propagate_inbounds Base.getindex(g::AbstractGrid, i) = getfield(g, :grid)[i]

Base.@propagate_inbounds function Base.getindex(grid::ParticlePositions{N}, idxs::Vector{Int}) where N
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

function Base.dropdims(grid::AbstractGrid{N}; dims) where N
    selected_dims = filter(i->i≠dims, Base.OneTo(N))

    g = ntuple(N-1) do i
        grid[selected_dims[i]]
    end
    if(any(isempty.(g)))
        empty(grid)
    end
    parameterless_type(grid)(g)
end
