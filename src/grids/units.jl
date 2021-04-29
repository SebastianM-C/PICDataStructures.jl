for f in (:ustrip, :uconvert)
    @eval begin
        function Unitful.$f(unit::Units, grid::AxisGrid)
            grid_axes = collect(grid)
            u_grid = map.(g->$f(unit, g), grid_axes)

            return AxisGrid(u_grid..., names=propertynames(grid))
        end

        function Unitful.$f(unit::Units, grid::SparseAxisGrid)
            grid_axes = collect(grid)
            u_grid = map(grid_axes) do g
                start = $f(unit, first(g))
                stop = $f(unit, last(g))
                if !(g isa AbstractUnitRange)
                    step = $f(unit, g.step)

                    start:step:stop
                else
                    step = oneunit(start)

                    start:stop
                end
            end

            return SparseAxisGrid(u_grid..., names=propertynames(grid))
        end

        function Unitful.$f(unit::Units, grid::ParticlePositions)
            grid_axes = collect(grid)
            u_grid = map.(g->$f(unit, g), grid_axes)

            names = propertynames(grid)
            mins = ($f).(minimum(grid))
            maxs = ($f).(maximum(grid))

            return ParticlePositions(u_grid...; names, mins, maxs)
        end
    end
end

function Unitful.ustrip(grid::AxisGrid)
    grid_axes = collect(grid)
    u_grid = map.(ustrip, grid_axes)

    return AxisGrid(u_grid..., names=propertynames(grid))
end

function Unitful.ustrip(grid::SparseAxisGrid)
    grid_axes = collect(grid)
    u_grid = map(grid_axes) do g
        start = ustrip(first(g))
        stop = ustrip(last(g))
        if !(g isa AbstractUnitRange)
            step = ustrip(g.step)

            start:step:stop
        else
            step = oneunit(start)

            start:stop
        end
    end

    return SparseAxisGrid(u_grid..., names=propertynames(grid))
end

function Unitful.ustrip(grid::ParticlePositions)
    grid_axes = collect(grid)
    u_grid = map.(ustrip, grid_axes)

    mins = ustrip.(minimum(grid))
    maxs = ustrip.(maximum(grid))
    names = propertynames(grid)

    return ParticlePositions(u_grid...; names, mins, maxs)
end
