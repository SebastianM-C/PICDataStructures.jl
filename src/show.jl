# Custom pretty-printing

Base.show(io::IO, ::MIME"text/plain", ::ScalarQuantity) = print(io, "Scalar")
Base.show(io::IO, ::MIME"text/plain", ::VectorQuantity) = print(io, "Vector")

function grid_description(grid)
    mins = minimum(grid)
    maxs = maximum(grid)

    join(join.(zip(mins, maxs), " … "), " × " )
end

function Base.show(io::IO, m::MIME"text/plain", f::AbstractPICDataStructure)
    show(io, m, scalarness(typeof(f)))
    data = getfield(f, :data)
    grid = getdomain(f)
    print(io, " with data:\n")
    ctx = IOContext(io, :limit=>true, :compact=>true, :displaysize => (10,50))
    Base.print_array(ctx, data)
    print(io, "\nand $(parameterless_type(typeof(grid))) grid ")
    print(io, grid_description(grid))
end
