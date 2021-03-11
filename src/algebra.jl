function LinearAlgebra.norm(field::T) where T<:AbstractPICDataStructure
    data = getfield(field, :data)
    grid = getfield(field, :grid)

    scalar_from(T)(norm.(data), grid)
end
