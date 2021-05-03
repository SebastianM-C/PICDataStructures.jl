for (f,_f) in zip((:ustrip, :uconvert), (:_ustrip, :_uconvert))
    @eval begin
        function Unitful.$f(unit::Units, grid::AxisGrid)
            grid_axes = collect(grid)
            u_grid = map.(g->$f(unit, g), grid_axes)

            return AxisGrid(u_grid..., names=propertynames(grid))
        end

        function Unitful.$f(unit::Units, grid::SparseAxisGrid)
            grid_axes = collect(grid)
            u_grid = map(grid_axes) do g
                $_f(unit, g)
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

for (f,u) in zip((:_ustrip, :_uconvert), (:ustrip, :uconvert))
    @eval begin
        function $f(u::Units, x::Base.TwicePrecision)
            lo = $u(u, x.lo)
            hi = $u(u, x.hi)

            Base.TwicePrecision(hi, lo)
        end

        function $f(u::Units, x::StepRange)
            start = $u(u, first(x))
            st = $u(u, step(x))
            stop = $u(u, last(x))

            StepRange(start, st, stop)
        end

        function $f(u::Units, x::StepRangeLen)
            ref = $f(u, x.ref)
            step = $f(u, x.step)

            StepRangeLen(ref, step, length(x))
        end
    end
end

function _ustrip(x::StepRange)
    start = ustrip(first(x))
    st = ustrip(step(x))
    stop = ustrip(last(x))

    StepRange(start, st, stop)
end

function _ustrip(x::StepRangeLen)
    ref = ustrip(x.ref)
    step = ustrip(x.step)

    StepRangeLen(ref, step, length(x))
end

function Unitful.ustrip(grid::AxisGrid)
    !hasunits(grid) && return grid
    grid_axes = collect(grid)
    u_grid = map.(ustrip, grid_axes)
    names = propertynames(grid)

    return AxisGrid(u_grid...; names)
end

function Unitful.ustrip(grid::SparseAxisGrid)
    !hasunits(grid) && return grid
    grid_axes = collect(grid)
    u_grid = map(_ustrip, grid_axes)
    names = propertynames(grid)

    return SparseAxisGrid(u_grid...; names)
end

function Unitful.ustrip(grid::ParticlePositions)
    !hasunits(grid) && return grid
    grid_axes = collect(grid)
    u_grid = map.(ustrip, grid_axes)

    mins = ustrip.(minimum(grid))
    maxs = ustrip.(maximum(grid))
    names = propertynames(grid)

    return ParticlePositions(u_grid...; names, mins, maxs)
end
