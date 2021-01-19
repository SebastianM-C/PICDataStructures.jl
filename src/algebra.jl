for f in (:+, :-,)
    @eval function (Base.$f)(f1::AbstractPICDataStructure, f2::AbstractPICDataStructure)
        @assert f1.grid == f2.grid "Incompatible grids"
        typeof(f1)(($f).(f1.data, f2.data), f1.grid)
    end
end

LinearAlgebra.norm(field::VectorField) = ScalarField(norm.(field), field.grid)
