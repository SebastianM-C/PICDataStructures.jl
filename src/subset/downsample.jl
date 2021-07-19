function ImageTransformations.imresize(f::AbstractPICDataStructure, target_size::Union{Integer, AbstractUnitRange}...)
    data = resize_data(unwrapdata(f), target_size...)
    grid = imresize(getdomain(f), target_size...)
    newstruct(f, data, grid)
end

function resize_data(data, target_size...)
    if hasunit(data)
        # use imresize directly on the underlying array
        T = recursive_unitless_bottom_eltype(data)
        data_units = recursive_bottom_unit(data)
        raw_data = reinterpret(T, data)
        resized_data = imresize(raw_data, target_size...)
        U = typeof(one(T) * data_units)
        reinterpret(U, resized_data)
    else
        imresize(data, target_size...)
    end
end

function resize_data(data::StructArray, target_size...)
    StructArray(map(c->imresize(collect(c), target_size), components(data)))
end

function ImageTransformations.imresize(g::AbstractAxisGrid, target_size...)
    grid_axes = collect(g)
    resized_axes = (imresize(collect(g), t) for (g,t) in zip(grid_axes, target_size))
    AxisGrid(resized_axes..., names=propertynames(g))
end

function ImageTransformations.imresize(g::ParticlePositions, target_size)
    grid_axes = collect(g)
    resized_axes = (imresize(g, target_size) for g in grid_axes)
    ParticlePositions(resized_axes..., names=propertynames(g))
end

function approx_target_size(::Type{T}) where T
    approx_target_size(domain_discretization(T), scalarness(T))
end
approx_target_size(::ParticleGrid, ::ScalarQuantity) = 7*10^5
approx_target_size(::ParticleGrid, ::VectorQuantity) = 70
approx_target_size(::LatticeGrid{1}, ::ScalarQuantity) = 600
approx_target_size(::LatticeGrid{2}, ::ScalarQuantity) = 400
approx_target_size(::LatticeGrid{3}, ::ScalarQuantity) = 120
approx_target_size(::LatticeGrid{2}, ::VectorQuantity) = 25
approx_target_size(::LatticeGrid{3}, ::VectorQuantity) = 15

"""
    downsample(f, target_size...)

Downsample the given input `f` to `target_size`. If no size is
provided, one is computed based on the type.
"""
function downsample(f, target_size...)
    # TODO: use restrict instead of imresize
    all(size(f) .> target_size) ? imresize(f, target_size...) : f
end

function downsample(f; approx_size=nothing)
    T = typeof(f)
    if isnothing(approx_size)
        sz = approx_target_size(T)
    else
        sz = approx_size
    end
    largest_dim = maximum(size(f))
    factor = largest_dim ÷ sz
    factor == 0 && return f
    target_size = map(i->i÷factor, size(f))
    @debug "Resizing to size $target_size from $(size(f))"
    downsample(f, target_size...)
end
