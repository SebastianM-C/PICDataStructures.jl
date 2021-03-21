function LinearAlgebra.norm(field::T) where T<:AbstractPICDataStructure
    data = unwrapdata(field)
    grid = getdomain(field)

    scalar_from(T)(norm.(data), grid)
end
