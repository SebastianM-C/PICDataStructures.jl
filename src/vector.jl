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

function VectorField(data::AbstractArray{T,M}, grid::G) where {N, M, G, T<:SArray{N}}
    VectorField{N}(data, grid)
end

function VectorVariable{N}(data::D, grid::G) where {N, M, T, D <: AbstractArray{T,M}, G}
    VectorVariable{N, M, T, D, G}(data, grid)
end

function VectorVariable(data::AbstractArray{T,M}, grid::G) where {N, M, P, G, S<:NTuple{N}, T<:NamedTuple{P,S}}
    VectorVariable{N}(data, grid)
end

function vector2nt(f::AbstractPICDataStructure, v::SArray{Tuple{N},T}) where {N,T}
    # @debug "Data type $(typeof(f.data)) and $(typeof(v))"
    names = propertynames(f)
    # @debug (; zip(names, v)...)
    NamedTuple{names, NTuple{N,T}}(v)
end

function vector2nt(data::StructArray, ::Type{<:SArray{Tuple{N},T}}) where {N,T}
    names = propertynames(data)
    # @debug N

    return NamedTuple{names, NTuple{N,T}}
end

function vector2nt(::StructArray, eltype::Type{<:Number})
    msg = "Cannot create vector with eltype $eltype. Are you trying to create a scalar?"
    throw(ArgumentError(msg))
end

function similar_data(data::StructArray{T}, ElType, dims) where T
    # @debug typeof(data) ElType
    S = vector2nt(data, ElType)
    StructArray{S}(map(typ -> similar(typ, dims), fieldarrays(data)))
end

# Indexing
Base.@propagate_inbounds function Base.getindex(f::VectorField{N}, i::Int) where N
    SVector{N}(unwrapdata(f)[i]...)
end
Base.@propagate_inbounds function Base.setindex!(f::VectorField, v::SVector, i::Int)
    # @debug typeof(f.data)
    unwrapdata(f)[i] = vector2nt(f, v)
end
Base.@propagate_inbounds function Base.getindex(f::VectorVariable{N}, i::Int) where N
    SVector{N}(unwrapdata(f)[i]...)
end
Base.@propagate_inbounds function Base.setindex!(f::VectorVariable, v::SVector, i::Int)
    unwrapdata(f)[i] = vector2nt(f, v)
end

Base.eltype(::VectorField{N,M,T}) where {N,M,T} = SVector{N,recursive_bottom_eltype(T)}
Base.eltype(::VectorVariable{N,M,T}) where {N,M,T} = SVector{N,recursive_bottom_eltype(T)}

function Base.similar(f::VectorField, ::Type{S}, dims::Dims) where S
    # @debug "Building similar vector field of type $S"
    parameterless_type(f)(StructArray(similar(unwrapdata(f), S, dims)), getdomain(f))
end

function Base.similar(f::VectorVariable, ::Type{S}, dims::Dims) where S
    # @debug "Building similar vector variable of type $S"
    parameterless_type(f)(StructArray(similar(unwrapdata(f), S, dims)), getdomain(f))
end

# Acessing the internal data storage by column names
get_property(f, key) = getproperty(unwrapdata(f), key)

Base.getproperty(f::VectorField, key::Symbol) = get_property(f, key)
Base.getproperty(f::VectorVariable, key::Symbol) = get_property(f, key)
Base.propertynames(f::VectorField) = propertynames(unwrapdata(f))
Base.propertynames(f::VectorVariable) = propertynames(unwrapdata(f))

vector_from(::Type{<:ScalarField}) = VectorField
vector_from(::Type{<:ScalarVariable}) = VectorVariable
scalar_from(::Type{<:VectorField}) = ScalarField
scalar_from(::Type{<:VectorVariable}) = ScalarVariable

function build_vector(components::NTuple{N, T}, names::NTuple{N, Symbol}) where {N, T}
    data_components = ntuple(N) do c
        getfield(components[c], :data)
    end
    data = StructArray(data_components; names)
    x = first(components)

    for c in components
        if c.grid ≠ x.grid
            @warn "Grids for vector variable may not be compatible"
        end
    end

    vectortype = vector_from(T)
    vectortype{N}(data, x.grid)
end
