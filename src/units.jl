function Unitful.ustrip(f::AbstractPICDataStructure)
    !hasunit(f) && return f
    data = unwrapdata(f)
    grid = getdomain(f)
    @debug "Stripping units for data of type $(typeof(data)) and grid $(typeof(grid))"
    udata = hasunit(data) ? ustrip_data(data) : data
    ugrid = ustrip(grid)

    newstruct(f, udata, ugrid)
end

# ustrip(A::Array) uses reinterpret and avoids creating a new array
ustrip_data(data) = ustrip(data)
ustrip_data(data::Base.ReinterpretArray) = reinterpret(recursive_unitless_bottom_eltype(data), data)
ustrip_data(data::StructArray) = StructArray(map(ustrip, components(data)))
ustrip_data(u, data) = ustrip.((u,), data)
ustrip_data(u, data::StructArray) = StructArray(map(c->ustrip.((u,),c), components(data)))
uconvert_data(u, data) = uconvert.((u,), data)
uconvert_data(u, data::StructArray) = StructArray(map(c->uconvert.((u,),c), components(data)))

for (f, ff) in zip((:uconvert, :ustrip), (:uconvert_data, :ustrip_data))
    @eval begin
        function (Unitful.$f)(u_data::Units, f::AbstractPICDataStructure)
            data = $ff(u_data, unwrapdata(f))
            grid = getdomain(f)

            newstruct(f, data, grid)
        end

        function (Unitful.$f)(u_data::Units, u_grid::Units, f::AbstractPICDataStructure)
            data = $ff(u_data, unwrapdata(f))
            grid = $f(u_grid, getdomain(f))

            newstruct(f, data, grid)
        end
    end
end

recursive_bottom_unit(f) = unit(recursive_bottom_eltype(f))
hasunit(f) = recursive_bottom_unit(f) ≠ NoUnits
hasunit(f::AbstractPICDataStructure) = hasunit(unwrapdata(f)) || hasunit(getdomain(f))
unitname(f) = hasunit(f) ? string(recursive_bottom_unit(f)) : ""
