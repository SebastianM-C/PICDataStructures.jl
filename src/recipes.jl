function AbstractPlotting.convert_arguments(P::Type{<:Volume}, f::ScalarField)
    grid = getdomain(f).grid
    data = getfield(f, :data)
    convert_arguments(P, grid..., data)
end

function AbstractPlotting.convert_arguments(P::Type{<:Contour}, f::ScalarField)
    grid = getdomain(f).grid
    data = getfield(f, :data)
    convert_arguments(P, grid..., data)
end

function AbstractPlotting.convert_arguments(P::Type{<:Scatter}, f::ScalarVariable)
    grid = getdomain(f).grid
    convert_arguments(P, grid...)
end
