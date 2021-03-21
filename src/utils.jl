for f in (:minimum, :maximum)
    @eval begin
        function (Base.$f)(grid::AbstractAxisGrid{N}) where N
            ntuple(N) do i
                $f(grid.grid[i])
            end
        end
    end
end

Base.minimum(g::ParticlePositions) = g.minvals
Base.maximum(g::ParticlePositions) = g.maxvals

getdomain(f::AbstractPICDataStructure) = getfield(f, :grid)
unwrapdata(f::AbstractPICDataStructure) = getfield(f, :data)

function broadcast_grid(f, g::NTuple{N}) where N
    ntuple(N) do i
        f.(g[i])
    end
end

function broadcast_grid(f, arg, g::NTuple{N}) where N
    ntuple(N) do i
        f.(arg, g[i])
    end
end
