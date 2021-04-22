abstract type AbstractVectorQuantity{T,N} <: AbstractArray{T,N} end

struct VectorQuantity end

struct VectorField{N,M,T,D<:AbstractArray{T,M},G<:AbstractAxisGrid} <: AbstractPICDataStructure{T,N,G}
    data::D
    grid::G
end

struct VectorVariable{N,M,T,D<:AbstractArray{T,M},G<:ParticlePositions} <: AbstractPICDataStructure{T,N,G}
    data::D
    grid::G
end

@inline scalarness(::Type{<:VectorField}) = VectorQuantity()
@inline scalarness(::Type{<:VectorVariable}) = VectorQuantity()

function VectorField{N}(data::D, grid::G) where {N, M, T, D <: AbstractArray{T,M}, G}
    VectorField{N, M, T, D, G}(data, grid)
end

function VectorField(data::AbstractArray{T,M}, grid::G) where {N, M, P, G, S<:NTuple{N}, T<:NamedTuple{P,S}}
    VectorField{N}(data, grid)
end

function VectorField(data::AbstractArray{T,M}, grid::G) where {N, M, G, T<:SArray{N}}
    VectorField{N}(data, grid)
end

function VectorVariable(data::D, grid::G) where {N, M, T, D <: AbstractArray{T,M}, G}
    VectorVariable{1, M, T, D, G}(data, grid)
end

function vector2nt(f::AbstractPICDataStructure, v::SArray{Tuple{N},T}) where {N,T}
    # @debug "Data type $(typeof(f.data)) and $(typeof(v))"
    names = propertynames(f)
    NamedTuple{names, NTuple{N,T}}(v)
end

function vector2nt(data::StructArray, ::Type{<:SArray{Tuple{N},T}}) where {N,T}
    names = propertynames(data)
    # @debug N

    return NamedTuple{names, NTuple{N,T}}
end

# Broadcasting

Base.BroadcastStyle(::VectorQuantity, ::Type{<:AbstractPICDataStructure}) = Broadcast.ArrayStyle{AbstractVectorQuantity}()

function similar_data(data::StructArray{T}, ElType, dims) where T
    @debug "Building similar StructArray with type $(typeof(data)) end eltype $ElType"
    S = vector2nt(data, ElType)

    props = propertynames(data)
    N = length(props)
    eltypes = NTuple{N, eltype(ElType)}
    @debug "Element eltypes: $eltypes"
    output_eltype = NamedTuple{props, eltypes}
    similar(similar_structarray(data, output_eltype), dims)
end

function Base.similar(bc::Broadcasted{ArrayStyle{AbstractVectorQuantity}}, ::Type{ElType}) where ElType
    # Scan the inputs for the AbstractPICDataStructure:
    f = find_field(bc)
    @debug "Building datastructure similar to $(typeof(f)) with eltype $ElType"
    grid = getdomain(f)
    # Keep the same grid for the output
    data = similar_data(unwrapdata(f), ElType, axes(bc))
    @debug "Output data type: $(typeof(data))"
    parameterless_type(f)(data, grid)
end

function Base.similar(bc::Broadcasted{ArrayStyle{AbstractVectorQuantity}}, ::Type{ElType}) where ElType <: Number
    # Scan the inputs for the AbstractPICDataStructure:
    f = find_field(bc)
    @debug "Building datastructure similar to $(typeof(f)) with eltype $ElType"
    grid = getdomain(f)
    # Keep the same grid for the output
    data = similar(unwrapdata(f), ElType, axes(bc))
    @debug "Output data type: $(typeof(data))"
    scalar_from(typeof(f))(data, grid)
end

# Indexing
@propagate_inbounds function Base.getindex(::VectorQuantity, v::T, i) where T
    N = dimensionality(T)
    SVector{N}(unwrapdata(v)[i]...)
end
@propagate_inbounds function Base.setindex!(::VectorQuantity, f, v::SVector, i::Int)
    # @debug typeof(f.data)
    unwrapdata(f)[i] = vector2nt(f, v)
end

function Base.eltype(::VectorQuantity, v::Type{T}) where T
    SVector{dimensionality(T),recursive_bottom_eltype(T)}
end

function Base.similar(f::VectorField, ::Type{S}, dims::Dims) where S
    # @debug "Building similar vector field of type $S"
    parameterless_type(f)(StructArray(similar(unwrapdata(f), S, dims)), getdomain(f))
end

function Base.similar(f::VectorVariable, ::Type{S}, dims::Dims) where S
    # @debug "Building similar vector variable of type $S"
    parameterless_type(f)(StructArray(similar(unwrapdata(f), S, dims)), getdomain(f))
end

# Acessing the internal data storage by column names
function get_componenet(f::T, key) where T
    data = getproperty(unwrapdata(f), key)
    grid = getdomain(f)

    scalar_from(T)(data, grid)
end

Base.getproperty(::VectorQuantity, f, key::Symbol) = get_componenet(f, key)
Base.propertynames(::VectorQuantity, f::AbstractPICDataStructure) = propertynames(unwrapdata(f))

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
    vectortype(data, x.grid)
end
