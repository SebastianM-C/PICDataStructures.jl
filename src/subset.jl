function ImageTransformations.imresize(f::AbstractPICDataStructure, target_size::Union{Integer, AbstractUnitRange}...)
    data = resize_data(unwrapdata(f), target_size...)
    grid = imresize(getdomain(f), target_size...)
    parameterless_type(f)(data, grid)
end

resize_data(data, target_size...) = imresize(data, target_size...)

function resize_data(data::StructArray, target_size...)
    StructArray(map(c->imresize(c, target_size), components(data)))
end

function ImageTransformations.imresize(g::AbstractAxisGrid{N}, target_size...) where N
    rg = ntuple(N) do i
        dim, t = g.grid[i], target_size[i]
        imresize(dim, t)
    end
    AxisGrid(rg)
end

function ImageTransformations.imresize(g::ParticlePositions, target_size)
    N = length(g)
    rg = ntuple(N) do i
        imresize(g.grid[i], target_size)
    end
    ParticlePositions(rg, g.minvals, g.maxvals)
end

function downsample(f, target_size...)
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

function location2idx(::LatticeGrid, f, dim, slice_location::Number)
    m, idx = findmin(map(x->abs(x-slice_location), getdomain(f)[dim]))
    @debug "Closest index to slice location $slice_location is $idx at $m"

    return idx
end

function location2idx(::ParticleGrid, f, dim, slice_location::Number; ϵ)
    grid = getdomain(f)
    idxs = filter(i->grid[dim][i] ∈ slice_location ± ϵ, axes(grid[dim], 1))
    @debug "Found $(length(idxs)) indices close to slice location $slice_location"

    return idxs
end

location2idx(::LatticeGrid, f, dim, idx::Int) = idx
location2idx(::LatticeGrid, f, dim, idx::AbstractVector) = idx
location2idx(::ParticleGrid, f, dim, idx::Int) = idx
location2idx(::ParticleGrid, f, dim, idx::AbstractVector) = idx

function Base.selectdim(f::T, dir::Union{Int,Symbol}, slice_location; kwargs...) where T <: AbstractPICDataStructure
    @debug "Generic slice fallback for AbstractPICDataStructure"
    selectdim(domain_discretization(T), f, dir, slice_location; kwargs...)
end

function Base.selectdim(::LatticeGrid, f::T, dir, slice_location) where T
    dim = dir_to_idx(dir)
    idx = location2idx(domain_discretization(T), f, dim, slice_location)
    selectdim(scalarness(T), f, dir, idx)
end

function Base.selectdim(::ParticleGrid, f::T, dir, slice_location; ϵ) where T
    dim = dir_to_idx(dir)
    idxs = location2idx(domain_discretization(T), f, dim, slice_location; ϵ)

    selectdim(scalarness(T), f, dir, idxs)
end

function Base.selectdim(::ScalarQuantity, f, dir, idx)
    dim = dir_to_idx(dir)
    data = selectdim(unwrapdata(f), dim, idx)
    grid = dropdims(getdomain(f), dims=dim)

    parameterless_type(f)(data, grid)
end

function Base.selectdim(::VectorQuantity, f, dir, idx)
    dim = dir_to_idx(dir)
    full_data = unwrapdata(f)
    grid = getdomain(f)

    sliced_data = selectdim(full_data, dim, idx)
    f_sliced = parameterless_type(f)(sliced_data, grid)
    f_reduced = dropdims(f_sliced, dims=dir)

    dropgriddims(f_reduced, dims=dir)
end

Base.dropdims(f::T; dims) where T <: AbstractPICDataStructure = dropdims(scalarness(T), f; dims)

function Base.dropdims(::VectorQuantity, f; dims)
    selected_dims = filter(c->c≠dims, propertynames(f))
    @debug "Selected dims: $selected_dims"
    data = unwrapdata(f)

    selected_data = StructArray(component.((data,), selected_dims), names=selected_dims)
    grid = getdomain(f)

    parameterless_type(f)(selected_data, grid)
end

function dropgriddims(f; dims)
    grid = getdomain(f)
    data = unwrapdata(f)
    sliced_grid = dropdims(grid; dims)

    parameterless_type(f)(data, sliced_grid)
end
