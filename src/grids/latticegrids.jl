abstract type AbstractAxisGrid{N,T,Names} <: AbstractGrid{N,T,Names} end

struct AxisGrid{N,T,V<:AbstractVector{T},Names} <: AbstractAxisGrid{N,T,Names}
    grid::NamedTuple{Names,NTuple{N,V}}
end

struct SparseAxisGrid{N,T,R<:AbstractRange{T},Names} <: AbstractAxisGrid{N,T,Names}
    grid::NamedTuple{Names,NTuple{N,R}}
end

for ax in (:AxisGrid, :SparseAxisGrid)
    @eval function $ax(args::Vararg{T,N}; names=:auto) where {N, T<:AbstractVector}
        names = replace_default_names(names, N)
        g = NamedTuple{names}(args)
        $ax(g)
    end
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

# This makes size(field) == size(grid)
Base.size(g::AbstractAxisGrid) = map(length, values(getdomain(g)))
