function location2idx(::LatticeGrid, f, dir, slice_location::Number)
    m, idx = findmin(map(x->abs(x-slice_location), getproperty(getdomain(f), dir)))
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

function Base.selectdim(f::T, dir::Symbol, slice_location; kwargs...) where T <: AbstractPICDataStructure
    @debug "Generic slice fallback for AbstractPICDataStructure"
    selectdim(domain_discretization(T), f, dir, slice_location; kwargs...)
end

function Base.selectdim(::LatticeGrid, f::T, dir, slice_location) where T
    idx = location2idx(domain_discretization(T), f, dir, slice_location)
    selectdim(scalarness(T), f, dir, idx)
end

function Base.selectdim(::ParticleGrid, f::T, dir, slice_location; ϵ) where T
    dim = dir_to_idx(dir)
    idxs = location2idx(domain_discretization(T), f, dim, slice_location; ϵ)

    selectdim(scalarness(T), f, dir, idxs)
end

function Base.selectdim(::ScalarQuantity, f, dir, idx)
    @debug "Scalar selectdim along $dir at index $idx"
    dim = dir_to_idx(dir)
    # TODO: Figure out if we can get rid of dir_to_idx
    data = selectdim(unwrapdata(f), dim, idx)
    grid = dropdims(getdomain(f), dims=dir)

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
