include("typerecipes.jl")

@recipe(FieldPlot) do scene
    Attributes(
        symmetric_cbar = false;
        :lengthscale => 1.0f0,
        # linewidth_factor = 1,
        :arrowsize => automatic,
        :linewidth => automatic,
        :color => automatic,
        :colormap => :viridis,
        :colorrange => automatic,
        :lowclip => nothing,
        :highclip => nothing,
        :inspectable => theme(scene, :inspectable),
        :levels => 6,
    )
end

@recipe(ScatterVariable) do scene
    Attributes(;
        lengthscale_factor = 1,
        # linewidth_factor = 1,
        :arrowsize => 1,
        :linewidth => 1,
        :color => automatic,
        :markersize => 8,
        :strokewidth => 1.0,
        :strokecolor => :black,
        :colormap => :viridis,
        :colorrange => automatic,
        :lowclip => nothing,
        :highclip => nothing,
        :inspectable => theme(scene, :inspectable),
    )
end

function MakieCore.plot!(sc::ScatterVariable{<:Tuple{ScalarVariable{T}}}) where {T}
    v = sc[1]
    grid, data = unwrap(v)

    scattergrid = Observable(empty(grid[]))
    scattercolor = Observable(Float32[])
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

    onany(update_plot, grid, data)

    update_plot(grid[], data[])

    scatter!(sc, scattergrid;
        sc.markersize,
        sc.strokewidth,
        sc.strokecolor,
        color=scattercolor,
        sc.colormap,
        sc.colorrange,
        sc.highclip,
        sc.lowclip,
        sc.inspectable
    )

    return sc
end

function MakieCore.plot!(sc::ScatterVariable{<:Tuple{VectorVariable{T}}}) where {T}
    v = sc[1]

    if hasunit(v)
        _v = @lift ustrip($v)
    else
        _v = v
    end

    arrow_norm = @lift Float32.(vec(norm.($_v)))
    maxarrow = @lift maximum(norm.($_v))

    # arrowsize = @lift $(sc.arrowsize_factor)*$arrow_norm
    lengthscale = @lift 1/$maxarrow
    # linewidth = @lift $(sc.linewidth_factor)*$arrow_norm
    valuerange = @lift extrema($arrow_norm)
    replace_automatic!(sc, :colorrange) do
        valuerange
    end

    replace_automatic!(sc, :colorrange) do
        valuerange
    end

    arrows!(sc, v;
        arrowcolor=arrow_norm,
        sc.arrowsize,
        linecolor=arrow_norm,
        lengthscale,
        sc.linewidth,
        sc.color,
        sc.colormap,
        sc.colorrange,
        sc.highclip,
        sc.lowclip,
        sc.inspectable
    )

    return sc
end

function symmetric_colorrange!(sc, f)
    onany(sc[:symmetric_cbar], f) do symmetric, f
        extr = map(vals->ustrip.(vals), extrema(f))
        if symmetric
            cl = map(e->max(abs.(e)...), extr)
            valuerange = map(c->(-c, c), cl)
        else
            valuerange = extr
        end
        replace_automatic!(sc, :colorrange) do
            valuerange
        end
    end
end

function MakieCore.plot!(sc::FieldPlot{<:Tuple{ScalarField{1}}})
    f = sc[1]

    grid, data = unwrap(f)

    symmetric_colorrange!(sc, f)
    notify(sc[:symmetric_cbar])

    lines!(sc, grid..., data;
        sc.colorrange,
        sc.colormap,
        sc.highclip,
        sc.lowclip,
        sc.inspectable
    )

    return sc
end

function MakieCore.plot!(sc::FieldPlot{<:Tuple{ScalarField{2}}})
    f = sc[1]

    grid, data = unwrap(f)

    symmetric_colorrange!(sc, f)
    notify(sc[:symmetric_cbar])

    heatmap!(sc, grid..., data;
        sc.colorrange,
        sc.colormap,
        sc.highclip,
        sc.lowclip,
        sc.inspectable
    )

    return sc
end

function MakieCore.plot!(sc::FieldPlot{<:Tuple{ScalarField{3}}})
    f = sc[1]

    symmetric_colorrange!(sc, f)
    notify(sc[:symmetric_cbar])
    @lift @debug "Contour plot for 3D ScalarField with " * string($(sc.levels)) * " levels"

    contour!(sc, f;
        sc.colorrange,
        sc.colormap,
        sc.color,
        sc.levels,
        sc.highclip,
        sc.lowclip,
        sc.inspectable
    )

    return sc
end

function MakieCore.plot!(sc::FieldPlot{<:Tuple{VectorField{N}}}) where N
    f = sc[1]

    if hasunit(f)
        _f = @lift ustrip($f)
    else
        _f = f
    end

    f_norm = @lift vec(norm.($_f))
    maxarrow = @lift maximum(norm.($_f))
    normed_f = @lift $_f ./ $maxarrow

    # linewidth = @lift $(sc.linewidth_factor)*$arrow_norm
    valuerange = @lift extrema($f_norm)
    replace_automatic!(sc, :colorrange) do
        valuerange
    end

    arrows!(sc, _f;
        arrowcolor = f_norm,
        arrowsize = lift(v->norm(v), _f),
        linecolor = f_norm,
        # sc.lengthscale,
        # sc.linewidth,
        markerspace = SceneSpace,
        sc.color,
        sc.colormap,
        sc.colorrange,
        sc.highclip,
        sc.lowclip,
        sc.inspectable
    )

    return sc
end
