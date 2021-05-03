include("typerecipes.jl")

@recipe(FieldPlot) do scene
    Attributes(
        lengthscale_factor = 1,
        # linewidth_factor = 1,
        arrowsize_factor = 1;
        :linewidth => 1,
        :color => AbstractPlotting.automatic,
        :colormap => :viridis,
        :colorrange => AbstractPlotting.automatic,
        :levels => 6,
    )
end

@recipe(ScatterVariable) do scene
    Attributes(
        lengthscale_factor = 1,
        # linewidth_factor = 1,
        arrowsize_factor = 1;
        :linewidth => 1,
        :color => AbstractPlotting.automatic,
        :markersize => 8,
        :strokewidth => 1.0,
        :strokecolor => :black,
        :colormap => :viridis,
        :colorrange => AbstractPlotting.automatic
    )
end

function AbstractPlotting.plot!(sc::ScatterVariable{<:Tuple{ScalarVariable{T}}}) where {T}
    v = sc[1]
    grid, data = unwrap(v)

    scattergrid = Node(empty(grid[]))
    scattercolor = Node(Float32[])
    cl = @lift ustrip(max(abs.(extrema($v))...))
    valuerange = @lift (-$cl, $cl)

    function update_plot(grid, color)
        empty!(scattergrid[])
        empty!(scattercolor[])

        append!(scattergrid[], grid)
        append!(scattercolor[], color)

        scattergrid[] = scattergrid[]
        scattercolor[] = scattercolor[]
    end

    replace_automatic!(sc, :colorrange) do
        valuerange
    end

    AbstractPlotting.Observables.onany(update_plot, grid, data)

    update_plot(grid[], data[])

    plt = scatter!(sc, scattergrid;
        color=scattercolor, sc.colorrange, sc.markersize,
        sc.strokewidth, sc.strokecolor, sc.colormap)

    return sc
end

function AbstractPlotting.plot!(sc::ScatterVariable{<:Tuple{VectorVariable{T}}}) where {T}
    v = sc[1]
    grid, data = unwrap(v)

    scattergrid = Node(empty(grid[]))

    arrow_norm = @lift Float32.(vec(norm.(ustrip($v))))
    maxarrow = @lift maximum(norm.(ustrip($v)))

    arrowsize = @lift $(sc.arrowsize_factor)*$arrow_norm
    lengthscale = @lift $(sc.lengthscale_factor)/$maxarrow
    # linewidth = @lift $(sc.linewidth_factor)*$arrow_norm
    valuerange = @lift extrema($arrow_norm)
    replace_automatic!(sc, :colorrange) do
        valuerange
    end

    function update_plot(grid)
        empty!(scattergrid[])

        append!(scattergrid[], grid)

        scattergrid[] = scattergrid[]
    end

    replace_automatic!(sc, :colorrange) do
        valuerange
    end

    AbstractPlotting.Observables.on(update_plot, grid)

    update_plot(grid[])

    plt = arrows!(sc, scattergrid;
        arrowcolor=arrow_norm,
        arrowsize,
        linecolor=arrow_norm,
        lengthscale,
        sc.linewidth,
        sc.color,
        sc.colormap,
        sc.colorrange)

    return sc
end

function AbstractPlotting.plot!(sc::FieldPlot{<:Tuple{ScalarField{1}}})
    f = sc[1]

    grid, data = unwrap(f)

    cl = @lift ustrip(max(abs.(extrema($f))...))
    valuerange = @lift (-$cl, $cl)
    replace_automatic!(sc, :colorrange) do
        valuerange
    end

    plt = lines!(sc, grid..., data; sc.colorrange, sc.colormap)

    return sc
end

function AbstractPlotting.plot!(sc::FieldPlot{<:Tuple{ScalarField{2}}})
    f = sc[1]

    grid, data = unwrap(f)

    cl = @lift ustrip(max(abs.(extrema($f))...))
    valuerange = @lift (-$cl, $cl)
    replace_automatic!(sc, :colorrange) do
        valuerange
    end

    plt = heatmap!(sc, grid..., data; sc.colorrange, sc.colormap)

    return sc
end

function AbstractPlotting.plot!(sc::FieldPlot{<:Tuple{ScalarField{3}}})
    f = sc[1]

    cl = @lift ustrip(max(abs.(extrema($f))...))
    valuerange = @lift (-$cl, $cl)
    replace_automatic!(sc, :colorrange) do
        valuerange
    end
    @lift @debug "Contour plot for 3D ScalarField with " * string($(sc.levels)) * " levels"

    plt = contour!(sc, f;
        sc.colorrange,
        sc.colormap,
        sc.color,
        sc.levels
    )

    return sc
end

function AbstractPlotting.plot!(sc::FieldPlot{<:Tuple{VectorField{N}}}) where N
    f = sc[1]

    arrow_norm = @lift Float32.(vec(norm.(ustrip($f))))
    maxarrow = @lift maximum(norm.(ustrip($f)))

    arrowsize = @lift $(sc.arrowsize_factor)*$arrow_norm
    lengthscale = @lift $(sc.lengthscale_factor)/$maxarrow
    # linewidth = @lift $(sc.linewidth_factor)*$arrow_norm
    valuerange = @lift extrema($arrow_norm)
    replace_automatic!(sc, :colorrange) do
        valuerange
    end

    plt = arrows!(sc, f;
        arrowcolor=arrow_norm,
        arrowsize,
        linecolor=arrow_norm,
        lengthscale,
        sc.linewidth,
        sc.color,
        sc.colormap,
        sc.colorrange
    )

    return sc
end
