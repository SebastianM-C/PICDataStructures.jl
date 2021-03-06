"""
    AbstractAxisGrid{N,T,Names}

An `AbstractAxisGrid` describes a structured grid in `N` dimensions.
Each axis has a name (form `Names`) and the type of the elements is `T`.
"""
abstract type AbstractAxisGrid{N,T,Names} <: AbstractGrid{N,T,Names} end

"""
    AxisGrid{N,Nm1,T,R,Names}

This is a `N` dimensional representation of a grid discretization which has
a structure where the discretization along each axis can be defined
through an `AbstractVector`. This implies that the discretization step
along each of the axes is not constant.
"""
struct AxisGrid{N,T,V<:AbstractVector{T},Nm1,Names} <: AbstractAxisGrid{N,T,Names}
    grid::NamedTuple{Names,Tuple{V,Vararg{V,Nm1}}}
end

function AxisGrid(grid::NamedTuple{Names,Tuple{V,Vararg{V,Nm1}}}) where {T,Nm1,Names,V<:AbstractVector{T}}
    N = Nm1 + 1
    AxisGrid{N,T,V,Nm1,Names}(grid)
end

"""
    SparseAxisGrid{N,Nm1,T,R,Names}

This is a `N` dimensional representation of a grid discretization which has
a regular structure where the discretization along each axis can be defined
through an `AbstractRange`. This implies that the grid can be defined
only through the start, stop and step for each axis.
"""
struct SparseAxisGrid{N,T,R<:AbstractRange{T},Nm1,Names} <: AbstractAxisGrid{N,T,Names}
    grid::NamedTuple{Names,Tuple{R,Vararg{R,Nm1}}}
end

function SparseAxisGrid(grid::NamedTuple{Names,Tuple{R,Vararg{R,Nm1}}}) where {T,Nm1,Names,R<:AbstractRange{T}}
    N = Nm1 + 1
    SparseAxisGrid{N,T,R,Nm1,Names}(grid)
end

# We need to ensure that we have at least one argument. N in Vararg{T,N} can be 0
for ax in (:AxisGrid, :SparseAxisGrid)
    @eval begin
        function $ax(args::Tuple{T,Vararg{T,Nm1}}; names=:auto) where {Nm1, T<:AbstractVector}
            N = Nm1 + 1

            names = replace_default_names(names, N)
            g = NamedTuple{names}(args)
            $ax(g)
        end

        function $ax(firstarg::T, args::Vararg{T,Nm1}; names=:auto) where {Nm1, T<:AbstractVector}
            all_args = (firstarg, args...)
            $ax(all_args; names)
        end
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

function Base.selectdim(g::AbstractAxisGrid, dir::Symbol, idx::Int)
    grid = getdomain(g)
    selected_axis = getproperty(g, dir)
    selection = selectdim(selected_axis, 1, idx:idx)

    new_grid = setindex!!(grid, selection, dir)

    return parameterless_type(g)(new_grid..., names=propertynames(grid))
end
