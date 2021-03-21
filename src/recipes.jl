function AbstractPlotting.convert_arguments(P::Type{<:Volume}, f::ScalarField)
    grid = getdomain(f).grid
    data = unwrapdata(f)
    convert_arguments(P, grid..., data)
end

function AbstractPlotting.convert_arguments(P::Type{<:Contour}, f::ScalarField)
    grid = getdomain(f).grid
    data = unwrapdata(f)
    convert_arguments(P, grid..., data)
end

function AbstractPlotting.convert_arguments(P::Type{<:Scatter}, g::ParticlePositions)
    convert_arguments(P, g.grid...)
end

@recipe(ScatterVariable) do scene
    Attributes(
        :size => 1,
        # :colormap => :viridis,
    )
end

function AbstractPlotting.plot!(sc::ScatterVariable{<:Tuple{ScalarVariable{N,T}}}) where {N,T}
    f = sc[1]
    grid = @lift getdomain($f)
    color = @lift unwrapdata($f)

    M = dimensionality(grid[])
    scattergrid = Node(ParticlePositions{M,T}())
    scattercolor = Node(Float32[])

    function update_plot(grid, color)
        empty!(scattergrid[])
        empty!(scattercolor[])

        append!(scattergrid[], grid)
        append!(scattercolor[], color)

        scattergrid[] = scattergrid[]
        scattercolor[] = scattercolor[]
    end

    AbstractPlotting.Observables.onany(update_plot, grid, color)

    update_plot(grid[], color[])

    plt = scatter!(sc, scattergrid, color=scattercolor, markersize=sc.size)

    return sc
end
