for f in (:+, :-,)
    @eval function (Base.$f)(f1::AbstractPICDataStructure, f2::AbstractPICDataStructure)
        @assert f1.grid == f2.grid "Incompatible grids"
        typeof(f1)(($f).(f1.data, f2.data), f1.grid)
    end
end

for f in (:sin, :cos, :tan, :acos, :asin, :atan, :acosh, :asinh, :atanh)
    @eval function (Base.$f)(field::F) where F<:AbstractPICDataStructure
        @assert f1.grid == f2.grid "Incompatible grids"
        F(($f).(field.data), field.grid)
    end
end

LinearAlgebra.norm(field::VectorField) = ScalarField(norm.(field.data), field.grid)
