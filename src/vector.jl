abstract type AbstractVectorQuantity{T,N} <: AbstractArray{T,N} end

struct VectorQuantity end

struct VectorField{N,M,T,D<:AbstractArray{T,M},G<:AbstractAxisGrid} <: AbstractPICDataStructure{T,N,G}
    data::D
    grid::G
    name::String
end

struct VectorVariable{T,D<:AbstractVector{T},G<:ParticlePositions} <: AbstractPICDataStructure{T,1,G}
    data::D
    grid::G
    name::String
end

@inline scalarness(::Type{<:VectorField}) = VectorQuantity()
@inline scalarness(::Type{<:VectorVariable}) = VectorQuantity()

function VectorField{N}(data::D, grid::G, name) where {N, M, T, D <: AbstractArray{T,M}, G}
    VectorField{N, M, T, D, G}(data, grid, name)
end

function VectorField(data::AbstractArray{T,M}, grid::G, name) where {N, M, P, G, S<:NTuple{N}, T<:NamedTuple{P,S}}
    @debug "Array of NamedTuple"
    VectorField{N}(data, grid, name)
end

VectorField(data, grid; name="") = VectorField(data, grid, name)

function VectorField(row_data::AbstractArray{T,M}, grid::G, names; name="") where {N, M, G, T<:SVector{N}}
    @debug "Building $(N)D VectorField row-wise from $T"
    ElType = NamedTuple{names, NTuple{N,recursive_bottom_eltype(row_data)}}
    @debug "Got ElType $ElType"
    data = StructArray{ElType}(undef, size(row_data))
    for i in eachindex(data, row_data)
        data[i] = vector2nt(data, row_data[i])
    end
    VectorField{N}(data, grid, name)
end

function VectorVariable(data::D, grid::G, name) where {M, T, D <: AbstractArray{T,M}, G}
    VectorVariable{M, T, D, G}(data, grid, name)
end

VectorVariable(data, grid; name="") = VectorVariable(data, grid, name)

function vector2nt(f, v::SArray{Tuple{N},T}) where {N,T}
    # @debug "Data type $(typeof(f.data)) and $(typeof(v))"
    names = propertynames(f)
    NamedTuple{names, NTuple{N,T}}(v)
end

# Broadcasting

Base.BroadcastStyle(::VectorQuantity, ::Type{<:AbstractPICDataStructure}) = Broadcast.ArrayStyle{AbstractVectorQuantity}()

function similar_data(data::StructArray{T}, ElType, dims) where T
    @debug "Building similar StructArray with type $(typeof(data)) end eltype $ElType"

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
    newstruct(f, data, grid)
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
    N = dimensionality(eltype(T))
    SVector{N}(unwrapdata(v)[i]...)
end
@propagate_inbounds function Base.setindex!(::VectorQuantity, f, v::SVector, i::Int)
    # @debug typeof(f.data)
    unwrapdata(f)[i] = vector2nt(f, v)
end

function Base.eltype(::VectorQuantity, v::Type{T}) where T
    SVector{dimensionality(T),recursive_bottom_eltype(T)}
end

function Base.similar(::VectorQuantity, f, ::Type{S}, dims::Dims) where S
    # @debug "Building similar VectorQuantity of type $S"
    data = StructArray(similar(unwrapdata(f), S, dims))
    grid = getdomain(f)
    newstruct(f, data, grid)
end

# Acessing the internal data storage by column names
function get_componenet(f::T, key) where T
    data = getproperty(unwrapdata(f), key)
    grid = getdomain(f)

    scalar_from(T)(data, grid)
end

Base.getproperty(::VectorQuantity, f::AbstractPICDataStructure, key::Symbol) = get_componenet(f, key)
Base.propertynames(::VectorQuantity, f::AbstractPICDataStructure) = propertynames(unwrapdata(f))

vector_from(::Type{<:ScalarField}) = VectorField
vector_from(::Type{<:ScalarVariable}) = VectorVariable
scalar_from(::Type{<:VectorField}) = ScalarField
scalar_from(::Type{<:VectorVariable}) = ScalarVariable

# build_vector must be called with at least one component. NTuple{N,T} can have N==0
function build_vector(components::Tuple{T, Vararg{T,N}}, names::Tuple{Symbol, Vararg{Symbol,N}}; name="") where {N, T}
    # We cannot have StructArrays with ScalarField components because we cannot
    # correctly build them through similar because StructArrays doens't have a
    # similar(::StructArray, ElType)
    # We fake this by creating the field in getproperty
    data_components = NamedTuple(name=>unwrapdata(c) for (name,c) in zip(names, components))
    data = StructArray(data_components)
    x = first(components)

    for c in components
        if c.grid ≠ x.grid
            @warn "Grids for vector variable may not be compatible"
        end
    end

    vectortype = vector_from(T)
    vectortype(data, x.grid; name)
end
