struct LatticeGrid{N} end
struct ParticleGrid end

domain_type(::Type{<:AbstractPICDataStructure{T,N,G}}) where {T,N,G} = parameterless_type(G)

function domain_discretization(::Type{<:AbstractPICDataStructure{T,N,G}}) where {T,N,G}
    domain_discretization(G)
end

domain_discretization(::Type{<:AbstractAxisGrid{N}}) where N = LatticeGrid{N}()
domain_discretization(::Type{<:ParticlePositions}) = ParticleGrid()
