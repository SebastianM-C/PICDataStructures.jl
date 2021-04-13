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

function slice(f::T, dir, slice_location, args...) where T <: AbstractPICDataStructure
    @debug "Generic slice fallback for AbstractPICDataStructure"
    slice(domain_discretization(T), f, dir, slice_location, args...)
end

function slice(f::T, dir, idx::Integer) where T <: AbstractPICDataStructure
    @debug "3-arg slice dispatching on scalarness"
    slice(scalarness(T), f, dir, idx)
end

function Base.selectdim(f::T, d::Union{Int,Symbol}, i::Integer) where T <: AbstractPICDataStructure
    selectdim(domain_discretization(T), f, d, i)
end

function slice(::ParticleGrid, f, dir, slice_location, ϵ)
    dim = dir_to_idx(dir)
    grid = getdomain(f)
    idxs = filter(i->grid[dim][i] ∈ slice_location ± ϵ, axes(grid[dim], 1))

    @debug "Slice at $slice_location gives $(length(idxs)) points"
    data = view(unwrapdata(f), idxs)
    grid_slice = dropdims(grid[idxs], dims=dim)

    parameterless_type(f)(data, grid_slice)
end

function slice(::ParticleGrid, f, dir, idx::Int, ϵ)
    dim = dir_to_idx(dir)
    grid = getdomain(f)
    idxs = filter(i->grid[dim][i] ∈ grid[dim][idx] ± ϵ, axes(grid[dim], 1))

    @debug "Slice at index $idx gives $(length(idxs)) points"
    data = view(unwrapdata(f), idxs)
    grid_slice = dropdims(grid[idxs], dims=dim)

    parameterless_type(f)(data, grid_slice)
end

function slice(::LatticeGrid, f, dir, slice_location)
    @debug "Generic slice on LatticeGrid"
    dim = dir_to_idx(dir)
    m, idx = findmin(map(x->abs(x-slice_location), getdomain(f)[dim]))
    slice(f, dir, idx)
end

slice(::ScalarQuantity, f, dir, idx) = selectdim(f, dir, idx)

function slice(::VectorQuantity, f, dir, idx)
    s = selectdim(f, dir, idx)
    dropdims(s, dims=dir)
end

function Base.selectdim(::LatticeGrid, f, dir, idx::Int)
    dim = dir_to_idx(dir)
    grid = getdomain(f)
    @debug "Slice along $dir ($dim) at: $(grid[dim][idx]) (idx $idx)"
    data = selectdim(unwrapdata(f), dim, idx)
    grid_slice = dropdims(grid, dims=dim)

    parameterless_type(f)(data, grid_slice)
end
