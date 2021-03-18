function Unitful.ustrip(f::AbstractPICDataStructure)
    data = ustrip_data(getfield(f, :data))
    grid = ustrip_grid(getdomain(f))

    parameterless_type(f)(data, grid)
end

ustrip_data(data) = ustrip.(data)
ustrip_data(data::StructArray) = StructArray(map(ustrip, fieldarrays(data)))

function ustrip_grid(g::NTuple{N}) where N
    ntuple(N) do i
        ustrip.(g[i])
    end
end

function ustrip_grid(g::AbstractAxisGrid)
    AxisGrid(ustrip_grid(g.grid))
end

function ustrip_grid(g::ParticlePositions{N}) where N
    ug = ustrip_grid(g.grid)
    min = ntuple(N) do i
        ustrip(g.minvals[i])
    end
    max = ntuple(N) do i
        ustrip(g.maxvals[i])
    end
    ParticlePositions(ug, min, max)
end

for f in (:uconvert, :ustrip)
    @eval begin
        function (Unitful.$f)(u_data::Units, f::AbstractPICDataStructure)
            data = map(d->($f)(u_data, d), getfield(f, :data))
            grid = getdomain(f)

            parameterless_type(f)(data, grid)
        end

        function (Unitful.$f)(u_data::Units, u_grid::Units, f::AbstractPICDataStructure)
            data = map(d->($f)(u_data, d), getfield(f, :data))
            grid = map.(d->($f)(u_grid, d), getdomain(f))

            parameterless_type(f)(data, grid)
        end

        function (Unitful.$f)(u_grid::Units, grid::AbstractAxisGrid)
            parameterless_type(grid)(($f)(u_grid, grid.grid))
        end

        function (Unitful.$f)(u_grid::Units, grid::ParticlePositions)
            g = ($f)(u_grid, grid.grid)
            minvals = ($f)(u_grid, grid.minvals)
            maxvals = ($f)(u_grid, grid.maxvals)

            parameterless_type(grid)(g, minvals, maxvals)
        end
    end
end
