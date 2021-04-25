function Unitful.ustrip(f::AbstractPICDataStructure)
    data = unwrapdata(f)
    grid = getdomain(f)
    @debug "Stripping units for data of type $(typeof(data)) and grid $(typeof(grid))"
    udata = ustrip_data(data)
    ugrid = ustrip(grid)

    parameterless_type(f)(udata, ugrid)
end

ustrip_data(data) = ustrip.(data)
ustrip_data(data::StructArray) = StructArray(map(ustrip, components(data)))
ustrip_data(u, data) = ustrip.((u,), data)
ustrip_data(u, data::StructArray) = StructArray(map(c->ustrip.((u,),c), components(data)))
uconvert_data(u, data) = uconvert.((u,), data)
uconvert_data(u, data::StructArray) = StructArray(map(c->uconvert.((u,),c), components(data)))

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
    ParticlePositions(ug, MVector(min), MVector(max))
end

for (f, ff) in zip((:uconvert, :ustrip), (:uconvert_data, :ustrip_data))
    @eval begin
        function (Unitful.$f)(units::Units, g::AbstractAxisGrid)
            AxisGrid(broadcast_grid($f, units, g.grid))
        end
        function (Unitful.$f)(units::Units, g::ParticlePositions{N}) where N
            ug = broadcast_grid($f, units, g.grid)
            min = ntuple(N) do i
                $f(units, g.minvals[i])
            end
            max = ntuple(N) do i
                $f(units, g.maxvals[i])
            end
            ParticlePositions(ug, MVector(min), MVector(max))
        end
        function (Unitful.$f)(u_data::Units, f::AbstractPICDataStructure)
            data = $ff(u_data, unwrapdata(f))
            grid = getdomain(f)

            parameterless_type(f)(data, grid)
        end

        function (Unitful.$f)(u_data::Units, u_grid::Units, f::AbstractPICDataStructure)
            data = $ff(u_data, unwrapdata(f))
            grid = $f(u_grid, getdomain(f))

            parameterless_type(f)(data, grid)
        end
    end
end

recursive_bottom_unit(f) = unit(recursive_bottom_eltype(f))
hasunits(f) = recursive_bottom_unit(f) ≠ NoUnits
unitname(f) = hasunits(f) ? string(recursive_bottom_unit(f)) : ""
