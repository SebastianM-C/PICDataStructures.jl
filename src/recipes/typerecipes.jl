function MakieCore.convert_arguments(P::DiscreteSurface, f::ScalarField)
    @debug "ScalarField SurfaceLike"
    grid, data = unwrap(f)

    convert_arguments(P, grid..., data)
end

function MakieCore.convert_arguments(P::VolumeLike, f::ScalarField{3})
    @debug "ScalarField VolumeLike"
    grid, data = unwrap(f)

    convert_arguments(P, grid..., data)
end

function MakieCore.convert_arguments(P::Type{<:Arrows}, f::VectorField{N}) where N
    @debug "VectorField Arrows"
    _f = hasunits(f) ? ustrip(f) : f

    grid = getdomain(_f)
    data = unwrapdata(_f)

    origins = vec(mapgrid(Point{N,Float32}, grid))
    arrowheads = vec(Vec{N,Float32}.(components(data)...))

    convert_arguments(P, origins, arrowheads)
end

function MakieCore.convert_arguments(P::Type{<:Arrows}, v::VectorVariable)
    @debug "VectorVariable Arrows"
    _v = hasunits(v) ? ustrip(v) : v
    N = dimensionality(v)

    grid = getdomain(_v)
    data = unwrapdata(_v)
    origins = mapgrid(Point{N,Float32}, grid)
    arrowheads = Vec{N,Float32}.(components(data)...)

    convert_arguments(P, origins, arrowheads)
end

function MakieCore.convert_arguments(P::Type{<:Contour}, f::ScalarField{3})
    @debug "ScalarField{3} with plot type $P"
    _f = hasunits(f) ? ustrip(f) : f
    grid, data = unwrap(_f)

    # 3D contour plots need the VolumeLike trait
    # plotting from the recipe creates a Contour{T} where T which defaults to SurfaceLike
    # In order to fix the problem, we create the correct type here
    P_fixed = Contour{Tuple{typeof.(grid)..., typeof(data)}}
    convert_arguments(P_fixed, grid..., data)
end

function MakieCore.convert_arguments(P::PointBased, g::ParticlePositions)
    @debug "PointBased ParticlePositions"
    convert_arguments(P, g...)
end
