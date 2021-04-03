function ImageTransformations.imresize(f::AbstractPICDataStructure, target_size::Union{Integer, AbstractUnitRange}...)
    parameterless_type(f)(imresize(f.data, target_size...), resize_grid(f.grid, target_size...))
end

function resize_grid(g::AbstractAxisGrid{N}, target_size...) where N
    rg = ntuple(N) do i
        dim, t = g.grid[i], target_size[i]
        imresize(dim, t)
    end
    AxisGrid(rg)
end

function resize_grid(g::ParticlePositions, target_size)
    N = length(g)
    rg = ntuple(N) do i
        imresize(g.grid[i], target_size)
    end
    ParticlePositions(rg, g.minvals, g.maxvals)
end

function downsample(f::AbstractPICDataStructure, target_size...)
    all(size(f) .> target_size) ? imresize(f, target_size...) : f
end

function dir_to_idx(dir::Symbol)
    if dir === :x
        1
    elseif dir === :y
        2
    elseif dir === :z
        3
    else
        0
    end
end

dir_to_idx(i::Int) = i

function Base.dropdims(grid::AbstractGrid{N}, dim) where N
    selected_dims = filter(i->i≠dim, Base.OneTo(N))

    g = ntuple(N-1) do i
        grid[selected_dims[i]]
    end
    if(any(isempty.(g)))
        empty(grid)
    end
    parameterless_type(grid)(g)
end

slice(f::T, args...) where T <: AbstractPICDataStructure = slice(domain_discretization(T), f, args...)

function slice(::ParticleGrid, f, dir, slice_location, ϵ)
    dim = dir_to_idx(dir)
    grid = getdomain(f)
    idxs = filter(i->grid[dim][i] ∈ slice_location ± ϵ, axes(grid[dim], 1))

    @debug "Slice at $slice_location gives $(length(idxs)) points"
    data = view(unwrapdata(f), idxs)
    grid_slice = dropdims(grid[idxs], dim)

    parameterless_type(f)(data, grid_slice)
end

function slice(::ParticleGrid, f, dir, idx::Int, ϵ)
    dim = dir_to_idx(dir)
    grid = getdomain(f)
    idxs = filter(i->grid[dim][i] ∈ grid[dim][idx] ± ϵ, axes(grid[dim], 1))

    @debug "Slice at index $idx gives $(length(idxs)) points"
    data = view(unwrapdata(f), idxs)
    grid_slice = dropdims(grid[idxs], dim)

    parameterless_type(f)(data, grid_slice)
end

function slice(::LatticeGrid, f, dir, slice_location)
    dim = dir_to_idx(dir)
    m, idx = findmin(map(x->abs(x-slice_location), getdomain(f)[dim]))
    slice(f, dir, idx)
end

function slice(::LatticeGrid, f, dir, idx::Int)
    dim = dir_to_idx(dir)
    grid = getdomain(f)
    @debug "Slice along $dir ($dim) at: $(grid[dim][idx]) (idx $idx)"
    data = selectdim(unwrapdata(f), dim, idx)
    grid_slice = dropdims(grid, dim)

    parameterless_type(f)(data, grid_slice)
end
