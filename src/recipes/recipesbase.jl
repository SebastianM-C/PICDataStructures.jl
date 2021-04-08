RecipesBase.@recipe function f(var::ScalarVariable{N}) where N
    marker_z --> unwrapdata(var)
    markersize --> 2.5
    markerstrokewidth --> 0
    aspect_ratio --> 1

    RecipesBase.@series begin
        seriestype := scatter
        x = getdomain(var)[1]
        y = getdomain(var)[2]
        if N > 2
            z = getdomain(var)[3]

            x, y, z
        else
            x, y
        end
    end
end

RecipesBase.@recipe function f(::Type{T}, f::T) where T <: ScalarField
    unwrapdata(f)
end
