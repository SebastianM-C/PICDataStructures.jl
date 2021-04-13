struct ScalarField{N,T,D<:AbstractArray{T,N},G} <: AbstractPICDataStructure{T,N}
    data::D
    grid::G
end

struct ScalarVariable{N,T,D<:AbstractArray{T,N},G} <: AbstractPICDataStructure{T,N}
    data::D
    grid::G
end

struct ScalarQuantity end
struct LatticeGrid{N} end

scalarness(::Type{<:ScalarField}) = ScalarQuantity()
scalarness(::Type{<:ScalarVariable}) = ScalarQuantity()

abstract type AbstractScalarQuantity{T,N} <: AbstractArray{T,N} end

Base.BroadcastStyle(::ScalarQuantity, ::Type{<:AbstractPICDataStructure}) = Broadcast.ArrayStyle{AbstractScalarQuantity}()

function Base.similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{AbstractScalarQuantity}}, ::Type{ElType}) where ElType
    # Scan the inputs for the AbstractPICDataStructure:
    f = find_field(bc)
    @debug "Building datastructure similar to $(typeof(f)) with eltype $ElType"
    grid = getdomain(f)
    # Keep the same grid for the output
    data_type = similar(unwrapdata(f), ElType, axes(bc))
    # @debug "Data type: $(typeof(data_type))"
    parameterless_type(f)(data_type, grid)
end
