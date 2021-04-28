Base.eltype(g::AbstractGrid{N,T}) where {N,T} = eltype(g.grid)

Base.length(g::AbstractGrid) = length(g.grid)
Base.iterate(g::AbstractGrid, state...) = iterate(getdomain(g), state...)

# This makes size(field) == size(grid)
Base.size(g::AbstractGrid) = map(length, values(getdomain(g)))

Base.getproperty(g::AbstractGrid, k::Symbol) = getfield(getfield(g, :grid), k)
Base.propertynames(g::AbstractGrid{N,T,Names}) where {N,T,Names} = Names

function Base.dropdims(grid::AbstractGrid{N}; dims) where N
    dir = dir_to_idx.(dims)
    selected_dims = filter(i->i≠dir, Base.OneTo(N))
    @debug "Selected grid dims: $selected_dims"

    g = ntuple(N-1) do i
        grid[selected_dims[i]]
    end
    if(any(isempty.(g)))
        empty(grid)
    end
    parameterless_type(grid)(g)
end

for f in (:minimum, :maximum)
    @eval begin
        function (Base.$f)(grid::AbstractAxisGrid{N}) where N
            ntuple(N) do i
                $f(getdomain(grid)[i])
            end
        end
    end
end
