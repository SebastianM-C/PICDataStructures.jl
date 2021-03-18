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
    minvals::NTuple{N,T}
    maxvals::NTuple{N,T}
end

Base.eltype(g::AbstractGrid{N,T}) where {N,T} = eltype(g.grid)

Base.length(g::AbstractGrid) = length(g.grid)
Base.iterate(g::AbstractGrid, state...) = iterate(g.grid, state...)

Base.@propagate_inbounds Base.getindex(g::AbstractGrid, i) = getfield(g, :grid)[i]
