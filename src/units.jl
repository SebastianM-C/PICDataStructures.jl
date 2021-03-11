function Unitful.ustrip(f::AbstractPICDataStructure)
    data = ustrip_data(getfield(f, :data))
    grid = ustrip_grid(getfield(f, :grid))

    parameterless_type(f)(data, grid)
end

ustrip_data(data) = ustrip.(data)
ustrip_data(data::StructArray) = StructArray(map(ustrip, fieldarrays(data)))
ustrip_grid(grid::AbstractArray) = ustrip.(grid)
ustrip_grid(grid::NTuple) = map.(ustrip, grid)

for f in (:uconvert, :ustrip)
    @eval begin
        function (Unitful.$f)(u_data::Units, f::AbstractPICDataStructure)
            data = map(d->($f)(u_data, d), getfield(f, :data))
            grid = getfield(f, :grid)

            parameterless_type(f)(data, grid)
        end

        function (Unitful.$f)(u_data::Units, u_grid::Units, f::AbstractPICDataStructure)
            data = map(d->($f)(u_data, d), getfield(f, :data))
            grid = map.(d->($f)(u_grid, d), getfield(f, :grid))

            parameterless_type(f)(data, grid)
        end
    end
end
