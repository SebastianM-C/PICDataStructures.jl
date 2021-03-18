function Unitful.ustrip(f::AbstractPICDataStructure)
    data = getfield(f, :data)
    grid = getdomain(f)
    @debug "Stripping units for data of type $(typeof(data)) and grid $(typeof(grid))"
    udata = ustrip_data(data)
    ugrid = ustrip(grid)

    parameterless_type(f)(udata, ugrid)
end

ustrip_data(data) = ustrip.(data)
ustrip_data(data::StructArray) = StructArray(map(ustrip, fieldarrays(data)))

function Unitful.ustrip(g::AbstractAxisGrid)
    AxisGrid(broadcast_grid(ustrip, g.grid))
end

function Unitful.ustrip(g::ParticlePositions{N}) where N
    ug = broadcast_grid(ustrip, g.grid)
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
        function (Unitful.$f)(units::Units, g::AbstractAxisGrid)
            AxisGrid(broadcast_grid($f, units, g.grid))
        end
        function (Unitful.$f)(units::Units, g::ParticlePositions{N}) where N
            ug = broadcast_grid($f, units, g.grid)
            min = ntuple(N) do i
                $f(g.minvals[i])
            end
            max = ntuple(N) do i
                $f(g.maxvals[i])
            end
            ParticlePositions(ug, min, max)
        end
        function (Unitful.$f)(u_data::Units, f::AbstractPICDataStructure)
            data = map(d->($f)(u_data, d), getfield(f, :data))
            grid = getdomain(f)

            parameterless_type(f)(data, grid)
        end

        function (Unitful.$f)(u_data::Units, u_grid::Units, f::AbstractPICDataStructure)
            data = map(d->($f)(u_data, d), getfield(f, :data))
            grid = ustrip(u_grid, getdomain(f))

            parameterless_type(f)(data, grid)
        end
    end
end
