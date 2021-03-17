function LinearAlgebra.norm(field::T) where T<:AbstractPICDataStructure
    data = getfield(field, :data)
    grid = getdomain(field)

    scalar_from(T)(norm.(data), grid)
end
