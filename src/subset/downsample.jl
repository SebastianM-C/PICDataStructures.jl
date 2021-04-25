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
