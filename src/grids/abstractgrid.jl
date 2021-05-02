Base.eltype(::AbstractGrid{N,T}) where {N,T} = T

Base.length(g::AbstractGrid) = length(getdomain(g))
Base.iterate(g::AbstractGrid, state...) = iterate(getdomain(g), state...)

Base.collect(g::AbstractGrid) = collect(getdomain(g))

Base.getproperty(g::AbstractGrid, k::Symbol) = getfield(getfield(g, :grid), k)
Base.propertynames(::AbstractGrid{N,T,Names}) where {N,T,Names} = Names

Base.isempty(g::AbstractGrid) = all(map(isempty, getdomain(g)))

function Base.dropdims(grid::AbstractGrid; dims)
    dims = dims isa Symbol ? (dims,) : dims
    selected_dims = (setdiff(propertynames(grid),dims)...,)
    @debug "Keeping grid dims: $selected_dims"

    selected = getproperty.((grid,), selected_dims)
    if(any(isempty.(selected)))
        empty(grid)
    end
    parameterless_type(grid)(selected...; names=selected_dims)
end

function Base.hash(g::AbstractGrid, h::UInt)
    data = getdomain(g)
    typename = Symbol(typeof(g))
    hash(data, hash(typename, h))
end

function Base.:(==)(a::AbstractGrid, b::AbstractGrid)
    typeof(a) == typeof(b) && getdomain(a) == getdomain(b) && true
end

function Base.isequal(a::AbstractGrid, b::AbstractGrid)
    d1 = getdomain(a)
    d2 = getdomain(b)
    t1 = typeof(a)
    t2 = typeof(b)
    isequal(t1, t2) && isequal(d1, d2) && true
end
