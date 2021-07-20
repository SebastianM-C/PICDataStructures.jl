function ImageTransformations.restrict(f::AbstractPICDataStructure)
    data = resize_data(unwrapdata(f))
    grid = restrict(getdomain(f))
    newstruct(f, data, grid)
end

function resize_data(data)
    if hasunit(data)
        # use imresize directly on the underlying array
        apply_reinterpret(restrict, data)
    else
        restrict(data)
    end
end

function resize_data(data::StructArray, target_size...)
    StructArray(map(c->resize_data(c), components(data)))
end

function ImageTransformations.restrict(g::AbstractAxisGrid)
    grid_axes = collect(g)
    resized_axes = (resize_data(collect(g)) for g in grid_axes)
    AxisGrid(resized_axes..., names=propertynames(g))
end

# TODO: Investigate if sampling can be a better solution for particle data
function ImageTransformations.restrict(g::ParticlePositions)
    grid_axes = collect(g)
    resized_axes = (restrict(g) for g in grid_axes)
    ParticlePositions(resized_axes..., names=propertynames(g))
end

function approx_target_size(::Type{T}) where T
    approx_target_size(domain_discretization(T), scalarness(T))
end
approx_target_size(::ParticleGrid, ::ScalarQuantity) = 7*10^5
approx_target_size(::ParticleGrid, ::VectorQuantity) = 70
approx_target_size(::LatticeGrid{1}, ::ScalarQuantity) = 600
approx_target_size(::LatticeGrid{2}, ::ScalarQuantity) = 400
approx_target_size(::LatticeGrid{3}, ::ScalarQuantity) = 200
approx_target_size(::LatticeGrid{2}, ::VectorQuantity) = 25
approx_target_size(::LatticeGrid{3}, ::VectorQuantity) = 15

"""
    downsample(f, target_size...)

Downsample the given input `f` to `target_size`. If no size is
provided, one is computed based on the type.
"""
function downsample(f, target_size...)
    all(size(f) .> target_size) ? downsample(restrict(f), target_size...) : f
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
