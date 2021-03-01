LinearAlgebra.norm(field::T) where T<:AbstractPICDataStructure = scalar_from(T)(norm.(field.data), field.grid)
