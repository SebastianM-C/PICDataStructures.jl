abstract type AbstractScalarQuantity{T,N} <: AbstractArray{T,N} end

struct ScalarQuantity end

struct ScalarField{N,T,D<:AbstractArray{T,N},G<:AbstractAxisGrid} <: AbstractPICDataStructure{T,N,G}
    data::D
    grid::G
    name::String
end


struct ScalarVariable{T,D<:AbstractVector{T},G<:ParticlePositions} <: AbstractPICDataStructure{T,1,G}
    data::D
    grid::G
    name::String
end

ScalarField(data, grid; name="") = ScalarField(data, grid, name)
ScalarVariable(data, grid; name="") = ScalarVariable(data, grid, name)

@inline scalarness(::Type{<:ScalarField}) = ScalarQuantity()
@inline scalarness(::Type{<:ScalarVariable}) = ScalarQuantity()

# Indexing
@propagate_inbounds Base.getindex(::ScalarQuantity, f, i) = unwrapdata(f)[i]
@propagate_inbounds Base.setindex!(::ScalarQuantity, f, v, i) = unwrapdata(f)[i] = v

Base.eltype(::ScalarQuantity, f::Type{<:AbstractPICDataStructure{T}}) where T = T

# Broadcasting

Base.BroadcastStyle(::ScalarQuantity, ::Type{<:AbstractPICDataStructure}) = Broadcast.ArrayStyle{AbstractScalarQuantity}()

function Base.similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{AbstractScalarQuantity}}, ::Type{ElType}) where ElType
    # Scan the inputs for the AbstractPICDataStructure:
    f = find_field(bc)
    @debug "Building datastructure similar to $(typeof(f)) with eltype $ElType"
    grid = getdomain(f)
    # Keep the same grid for the output
    data = similar(unwrapdata(f), ElType, axes(bc))
    @debug "Output data type: $(typeof(data))"
    newstruct(f, data, grid)
end

function Base.similar(::ScalarQuantity, f, ::Type{S}, dims::Dims) where S
    # @debug "similar ScalarQuantity"
    grid = getdomain(f)
    data = similar(unwrapdata(f), S, dims)
    newstruct(f, data, grid)
end

Base.getproperty(::ScalarQuantity, f::AbstractPICDataStructure, key::Symbol) = getfield(f, key)
Base.propertynames(::ScalarQuantity, f::AbstractPICDataStructure) = fieldnames(typeof(f))
