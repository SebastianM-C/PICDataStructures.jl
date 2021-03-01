struct VectorField{N,M,T,D<:AbstractArray{T,M},G} <: AbstractPICDataStructure{T,N}
    data::D
    grid::G
end

struct VectorVariable{N,M,T,D<:AbstractArray{T,M},G} <: AbstractPICDataStructure{T,N}
    data::T
    grid::G
end

function VectorField{N}(data::D, grid::G) where {N, M, T, D <: AbstractArray{T,M}, G}
    VectorField{N, M, T, D, G}(data, grid)
end

function VectorVariable{N}(data::D, grid::G) where {N, M, T, D <: AbstractArray{T,M}, G}
    VectorVariable{N, M, T, D, G}(data, grid)
end

# Indexing
Base.@propagate_inbounds Base.getindex(f::VectorField{N}, i::Int) where N = SVector{N}(f.data[i]...)
Base.@propagate_inbounds Base.setindex!(f::VectorField, v, i::Int) = f.data[i] = v
Base.@propagate_inbounds Base.getindex(f::VectorVariable{N}, i::Int) where N = SVector{N}(f.data[i]...)
Base.@propagate_inbounds Base.setindex!(f::VectorVariable, v, i::Int) = f.data[i] = v

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
