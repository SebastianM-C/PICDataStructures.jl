domain_type(::Type{<:ScalarField{N,T,D,G}}) where {N,T,D,G} = parameterless_type(G)
domain_type(::Type{<:ScalarVariable{N,T,D,G}}) where {N,T,D,G} = parameterless_type(G)
domain_type(::Type{<:VectorField{N,M,T,D,G}}) where {N,M,T,D,G} = parameterless_type(G)
domain_type(::Type{<:VectorVariable{N,M,T,D,G}}) where {N,M,T,D,G} = parameterless_type(G)

domain_discretization(::Type{<:ScalarField{N}}) where N = LatticeGrid{N}()
domain_discretization(::Type{<:ScalarVariable}) where N = ParticleGrid()
domain_discretization(::Type{<:VectorField{N}}) where N = LatticeGrid{N}()
domain_discretization(::Type{<:VectorVariable}) where N = ParticleGrid()
