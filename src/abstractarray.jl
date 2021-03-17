# Indexing
Base.@propagate_inbounds Base.getindex(f::AbstractPICDataStructure, i::Int) = getfield(f, :data)[i]
Base.@propagate_inbounds Base.setindex!(f::AbstractPICDataStructure, v, i::Int) = getfield(f, :data)[i] = v

Base.firstindex(f::AbstractPICDataStructure) = firstindex(getfield(f, :data))
Base.lastindex(f::AbstractPICDataStructure) = lastindex(getfield(f, :data))

Base.size(f::AbstractPICDataStructure, dim...) = size(getfield(f, :data), dim...)

Base.LinearIndices(f::AbstractPICDataStructure) = LinearIndices(getfield(f, :data))
Base.IndexStyle(::Type{<:AbstractPICDataStructure}) = Base.IndexLinear()

# Iteration
Base.iterate(f::AbstractPICDataStructure, state...) = iterate(getfield(f, :data), state...)
Base.length(f::AbstractPICDataStructure) = length(getfield(f, :data))

# Broadcasting
Base.BroadcastStyle(::Type{<:AbstractPICDataStructure}) = Broadcast.ArrayStyle{AbstractPICDataStructure}()

similar_data(data, ElType, dims) = similar(data, ElType, dims)

function Base.similar(f::AbstractPICDataStructure, ::Type{S}, dims::Dims) where S
    # @debug "similar AbstractPICDataStructure"
    parameterless_type(f)(similar(getfield(f, :data), S, dims), getdomain(f))
end

function Base.similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{AbstractPICDataStructure}}, ::Type{ElType}) where ElType
    # Scan the inputs for the AbstractPICDataStructure:
    f = find_field(bc)
    @debug "Building datastructure similar to $(typeof(f)) with eltype $ElType"
    grid = getdomain(f)
    # Keep the same grid for the output
    data_type = similar_data(getfield(f, :data), ElType, axes(bc))
    # @debug "Data type: $(typeof(data_type))"
    parameterless_type(f)(data_type, grid)
end

"""
`A = find_filed(Fs)` returns the first `AbstractPICDataStructure` among the arguments.
"""
function find_field(bc::Base.Broadcast.Broadcasted)
    # @debug "Destructuring Broadcasted $(typeof(bc.args))"
    find_field(bc.args)
end
function find_field(args::Tuple)
    # @debug "First argument in broadcast: $(typeof(first(args)))"
    find_field(find_field(first(args)), Base.tail(args))
end
function find_field(f)
    # @debug "Any fallback got $(typeof(f))"
    f
end
find_field(::Tuple{}) = nothing
function find_field(f::AbstractPICDataStructure, rest)
    # @debug "Found AbstractPICDataStructure $(typeof(f))"
    f
end
function find_field(::Any, rest)
    # @debug "Recursing in the second argument $(typeof(rest))"
    find_field(rest)
end
