struct VectorField{N,M,T,D<:AbstractArray{T,M},G} <: AbstractPICDataStructure{T,N}
    data::D
    grid::G
end

struct VectorVariable{N,M,T,D<:AbstractArray{T,M},G} <: AbstractPICDataStructure{T,N}
    data::D
    grid::G
end

function VectorField{N}(data::D, grid::G) where {N, M, T, D <: AbstractArray{T,M}, G}
    VectorField{N, M, T, D, G}(data, grid)
end

function VectorField(data::AbstractArray{T,M}, grid::G) where {N, M, P, G, S<:NTuple{N}, T<:NamedTuple{P,S}}
    VectorField{N}(data, grid)
end

function VectorVariable{N}(data::D, grid::G) where {N, M, T, D <: AbstractArray{T,M}, G}
    VectorVariable{N, M, T, D, G}(data, grid)
end

function VectorVariable(data::AbstractArray{T,M}, grid::G) where {N, M, P, G, S<:NTuple{N}, T<:NamedTuple{P,S}}
    VectorVariable{N}(data, grid)
end

function vector2nt(f::AbstractPICDataStructure, v::SVector)
    # @debug typeof(f.data)
    names = keys(fieldarrays(f.data))
    (; zip(names, v)...)
end

# Indexing
Base.@propagate_inbounds Base.getindex(f::VectorField{N}, i::Int) where N = SVector{N}(f.data[i]...)
Base.@propagate_inbounds Base.setindex!(f::VectorField, v::SVector, i::Int) = f.data[i] = vector2nt(f, v)
Base.@propagate_inbounds Base.getindex(f::VectorVariable{N}, i::Int) where N = SVector{N}(f.data[i]...)
Base.@propagate_inbounds Base.setindex!(f::VectorVariable, v::SVector, i::Int) = f.data[i] = vector2nt(f, v)


# Acessing the internal data storage by column names
get_property(f, key) = Base.sym_in(key, propertynames(f)) ? getfield(f, key) : getproperty(f.data, key)

Base.getproperty(f::VectorField, key::Symbol) = get_property(f, key)
Base.getproperty(f::VectorVariable, key::Symbol) = get_property(f, key)

vector_from(::Type{<:ScalarField}) = VectorField
vector_from(::Type{<:ScalarVariable}) = VectorVariable
scalar_from(::Type{<:VectorField}) = ScalarField
scalar_from(::Type{<:VectorVariable}) = ScalarVariable

function build_vector(components::NTuple{N, T}, names::NTuple{N, Symbol}) where {N, T}
    data = StructArray(components; names)
    x = first(components)

    for c in components
        if c.grid ≠ x.grid
            @warn "Grids for vector variable may not be compatible"
        end
    end

    vectortype = vector_from(T)
    vectortype{N}(data, x.grid)
end
