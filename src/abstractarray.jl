# Indexing
@propagate_inbounds function Base.getindex(f::T, i::Int) where T <: AbstractPICDataStructure
    getindex(scalarness(T), f, i)
end
@propagate_inbounds function Base.setindex!(f::T, v, i::Int) where T <: AbstractPICDataStructure
    setindex!(scalarness(T), f, v, i)
end

Base.firstindex(f::AbstractPICDataStructure) = firstindex(unwrapdata(f))
Base.lastindex(f::AbstractPICDataStructure) = lastindex(unwrapdata(f))

function Base.size(f::AbstractPICDataStructure, dim...)
    size(unwrapdata(f), dim...)
end

Base.LinearIndices(f::AbstractPICDataStructure) = LinearIndices(unwrapdata(f))
Base.IndexStyle(::Type{<:AbstractPICDataStructure}) = Base.IndexLinear()

Base.eltype(::T) where T <: AbstractPICDataStructure = eltype(scalarness(T), T)

# Iteration
Base.iterate(f::AbstractPICDataStructure, state...) = iterate(unwrapdata(f), state...)
Base.length(f::AbstractPICDataStructure) = length(unwrapdata(f))

# Broadcasting
Base.BroadcastStyle(::Type{T}) where T<:AbstractPICDataStructure = Base.BroadcastStyle(scalarness(T), T)

function Base.similar(f::AbstractPICDataStructure, ::Type{S}, dims::Dims) where S
    @debug "similar AbstractPICDataStructure"
    parameterless_type(f)(similar(unwrapdata(f), S, dims), getdomain(f))
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
