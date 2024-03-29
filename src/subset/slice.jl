function location2idx(::LatticeGrid, f, dir, slice_location::Number)
    m, idx = findmin(map(x->abs(x-slice_location), getproperty(getdomain(f), dir)))
    @debug "Closest index to slice location $slice_location is $idx at $m"

    return idx
end

function location2idx(::ParticleGrid, f, dir, slice_location::Number; ϵ)
    grid = getdomain(f)
    grid_axis = getproperty(grid, dir)
    idxs = filter(i->grid_axis[i] ∈ slice_location ± ϵ, axes(grid_axis, 1))
    @debug "Found $(length(idxs)) indices close to slice location $slice_location"

    return idxs
end

function Base.selectdim(f::T, dir::Symbol, slice_location; kwargs...) where T <: AbstractPICDataStructure
    @debug "Generic slice fallback for AbstractPICDataStructure"
    idx = location2idx(domain_discretization(T), f, dir, slice_location; kwargs...)
    selectdim(scalarness(T), domain_discretization(T), f, dir, idx)
end

function Base.selectdim(::ScalarQuantity, ::LatticeGrid, f, dir, idx)
    @debug "Scalar selectdim along $dir at index $idx"
    dim = dir_to_idx(dir)
    # TODO: Figure out if we can get rid of dir_to_idx
    data = selectdim(unwrapdata(f), dim, idx)
    grid = dropdims(getdomain(f), dims=dir)

    newstruct(f, data, grid)
end

function Base.selectdim(::ScalarQuantity, ::ParticleGrid, f, dir, idx)
    @debug "Scalar selectdim along $dir at index $idx"
    dim = dir_to_idx(dir)
    # TODO: Figure out if we can get rid of dir_to_idx
    data = selectdim(unwrapdata(f), dim, idx)
    grid_lower_dim = dropdims(getdomain(f), dims=dir)

    grid = selectdim(grid_lower_dim, dir, idx)

    newstruct(f, data, grid)
end

function Base.selectdim(::VectorQuantity, ::LatticeGrid, f, dir, idx::Int)
    dim = dir_to_idx(dir)
    full_data = unwrapdata(f)
    grid = getdomain(f)

    sliced_data = selectdim(full_data, dim, idx:idx)
    f_sliced = newstruct(f, sliced_data, grid)
    f_reduced = dropdims(f_sliced, dims=dir)

    dropgriddims(f_reduced, dims=dir)
end

function Base.selectdim(::VectorQuantity, ::ParticleGrid, v, dir, idx)
    @debug "Vector selectdim along $dir at index $idx"
    full_data = unwrapdata(v)
    dim = dir_to_idx(dir)

    grid_lower_dim = dropdims(getdomain(v), dims=dir)
    grid = selectdim(grid_lower_dim, dir, idx)
    @debug grid
    # TODO: Figure out if we can get rid of dir_to_idx
    sliced_data = selectdim(full_data, dim, idx)
    @debug sliced_data
    data = removedims(sliced_data; dims=dir)

    newstruct(v, data, grid)
end

function removedims(data; dims)
    dims = dims isa Symbol ? (dims,) : dims
    selected_dims = (setdiff(propertynames(data),dims)...,)
    @debug "Keeping grid dims: $selected_dims"

    StructArray(component.((data,), selected_dims), names=selected_dims)
end

Base.dropdims(f::T; dims) where T <: AbstractPICDataStructure = dropdims(scalarness(T), f; dims)

function Base.dropdims(::VectorQuantity, f; dims)
    data_rm = removedims(unwrapdata(f); dims)
    dim = dir_to_idx.(dims)
    data = dropdims(data_rm; dims=dim)
    grid = getdomain(f)

    newstruct(f, data, grid)
end

function Base.dropdims(::ScalarQuantity, f; dims)
    dim = dir_to_idx.(dims)
    data = dropdims(unwrapdata(f); dims=dim)
    grid = dropdims(getdomain(f); dims)

    newstruct(f, data, grid)
end

function dropgriddims(f; dims)
    grid = getdomain(f)
    data = unwrapdata(f)
    sliced_grid = dropdims(grid; dims)

    newstruct(f, data, sliced_grid)
end
