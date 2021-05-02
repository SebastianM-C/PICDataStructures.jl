struct ParticlePositions{N,T,V<:AbstractVector{T},Nm1,Names} <: AbstractGrid{N,T,Names}
    grid::NamedTuple{Names,Tuple{V,Vararg{V,Nm1}}}
    minvals::MVector{N,T}
    maxvals::MVector{N,T}
end

# We need to ensure that we have at least one argument
function ParticlePositions(firstarg::T, args::Vararg{T,Nm1};
    names=:auto, mins=:auto, maxs=:auto) where {Nm1, T<:AbstractVector}

    N = Nm1 + 1
    all_args = (firstarg, args...)
    names = replace_default_names(names, N)
    grid = NamedTuple{names}(all_args)

    mins = mins == :auto ? MVector(map(minimum, all_args)) : mins
    maxs = maxs == :auto ? MVector(map(maximum, all_args)) : maxs

    ParticlePositions(grid, mins, maxs)
end

function ParticlePositions{N,T}(::UndefInitializer) where {N,T}
    grid = ntuple(N) do i
        T[]
    end
    mins = MVector{N,T}(undef)
    maxs = MVector{N,T}(undef)

    ParticlePositions(grid...; mins, maxs)
end

function Base.empty!(grid::ParticlePositions{N,T}) where {N,T}
    for grid_dir in grid
        empty!(grid_dir)
    end
    mins = minimum(grid)
    maxs = maximum(grid)
    mins .= typemax(T)
    maxs .= typemin(T)

    return grid
end

function Base.empty(::ParticlePositions{N,T}) where {N,T}
    undefp = ParticlePositions{N,T}(undef)
    getfield(undefp, :minvals) .= typemax(T)
    getfield(undefp, :maxvals) .= typemin(T)

    return undefp
end

function Base.append!(grid::ParticlePositions, new_grid::ParticlePositions)
    for (grid_dir, new_g) in zip(grid, new_grid)
        append!(grid_dir, new_g)
    end
    mins = minimum(grid)
    maxs = maximum(grid)
    new_mins = minimum(new_grid)
    new_maxs = maximum(new_grid)
    for (m,nm) in zip(mins, new_mins)
        if nm > m
            m = nm
        end
    end
    for (m,nm) in zip(maxs, new_maxs)
        if nm > m
            m = nm
        end
    end

    return grid
end

# This makes size(field) == size(grid)
Base.size(g::ParticlePositions) = (length(first(g)), )

Base.minimum(g::ParticlePositions) = getfield(g, :minvals)
Base.maximum(g::ParticlePositions) = getfield(g, :maxvals)

Base.sort(g::ParticlePositions, dir) = ParticlePositions(sort(getproperty(g, dir)), g.minvals, g.maxvals)

function Base.sort!(f::T, dim) where T <: AbstractPICDataStructure
    sort!(domain_discretization(T), f, dim)
end

function Base.sort!(::ParticleGrid, f, dir)
    grid = getdomain(f)
    sort_idx = sortperm(getproperty(grid, dim))
    permute!.(grid, (sort_idx,))
    permute!(unwrapdata(f), sort_idx)

    return f
end
