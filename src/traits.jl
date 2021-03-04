struct ScalarQuantity end
struct VectorQuantity end
struct LatticeGrid end
struct ParticleGrid end

scalarness(::Type{<:ScalarField}) = ScalarQuantity()
scalarness(::Type{<:ScalarVariable}) = ScalarQuantity()
scalarness(::Type{<:VectorField}) = VectorQuantity()
scalarness(::Type{<:VectorVariable}) = VectorQuantity()

domain_type(::Type{<:ScalarField{N,T,D,G}}) where {N,T,D,G} = parameterless_type(G)
domain_type(::Type{<:ScalarVariable{N,T,D,G}}) where {N,T,D,G} = parameterless_type(G)
domain_type(::Type{<:VectorField{N,M,T,D,G}}) where {N,M,T,D,G} = parameterless_type(G)
domain_type(::Type{<:VectorVariable{N,M,T,D,G}}) where {N,M,T,D,G} = parameterless_type(G)

domain_discretization(::Type{<:ScalarField}) = LatticeGrid()
domain_discretization(::Type{<:ScalarVariable}) = ParticleGrid()
domain_discretization(::Type{<:VectorField}) = LatticeGrid()
domain_discretization(::Type{<:VectorVariable}) = ParticleGrid()