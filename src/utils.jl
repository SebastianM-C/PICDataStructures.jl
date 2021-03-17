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
