include("abstractplotting.jl")

"""
    plotdata(f::AbstractPICDataStructure; kwargs...)

Universal plotting function for `AbstractPICDataStructure`s.
It uses [`fieldplot`](@ref) or [`scattervariable`](@ref) depending
of the input type of `f` and adds a colorbar.

### Keyword arguments
- `fig`: The `Figure` in which to add the plot. By default it creates a new figure with `Figure()`
- `figurepos`: The `FigurePosition` to use. The default is `fig[1,1]`
- `xlabel`: The labes of the x axis of the figure. By default is determined with [`axisnames`](@ref)
- `ylabel`: The labes of the y axis of the figure. By default is determined with [`axisnames`](@ref)
- `zlabel`: The labes of the z axis of the figure. By default is determined with [`axisnames`](@ref)
- `title`: The figure title. Empty (`""`) by default
- `downsample_size`: Thw approximate downsample size for the input data.
By default (`:default`), it uses the heuristic values in [`downsample`](@ref).
If you want to avoid downsampling the data, use `nothing`.
Otherwise, the argument is the approximate maiximun size along any direction.
- `cbar_orientation`: The orientation of the attached `Colorbar`. By default is `:vertical`.
- `cbar_label`: The `Colorbar` label. Empty (`""`) by default.
- `saveplot`: Whether to save the plot or not. Default is `false`.
- `filename`: The filename to use if saving the plot.

Any additional Keyword arguments are passed to the internal plotting function
([`fieldplot`](@ref) or [`scattervariable`](@ref)).
"""
plotdata(f::AbstractPICDataStructure; kwargs...) = plotdata(Observable(f); kwargs...)

function plotdata(f::Observable;
    fig = Figure(),
    figurepos = fig[1,1],
    xlabel = :auto,
    ylabel = :auto,
    zlabel = :auto,
    title = "",
    downsample_size = :default,
    cbar_orientation = :vertical,
    cbar_label = "",
    saveplot = false,
    filename = "$(scalarness(typeof(f[])))_plot.png",
    kwargs...)

    first_f = f[]
    is2D = dimensionality(first_f) < 3
    if is2D
        @debug "2D plots"
        if dimensionality(first_f) == 1
            xlabel = xlabel == :auto ? only(axisnames(first_f)) : xlabel
            # ylabel = nameof(f)
            ylabel = ""
            aspect = AxisAspect(1)
        else
            _xlabel, _ylabel = axisnames(first_f)
            xlabel = xlabel == :auto ? _xlabel : xlabel
            ylabel = ylabel == :auto ? _ylabel : ylabel
            aspect = DataAspect()
        end

        ax = Axis(figurepos[1,1];
            xlabel, ylabel,
            title,
            aspect
        )
    else
        _xlabel, _ylabel, _zlabel = axisnames(first_f)
        xlabel = xlabel == :auto ? _xlabel : xlabel
        ylabel = ylabel == :auto ? _ylabel : ylabel
        zlabel = zlabel == :auto ? _zlabel : zlabel

        ax = LScene(figurepos[1,1];
            axis = (names = (axisnames = (xlabel, ylabel, zlabel),),)
        )
    end

    if isnothing(downsample_size)
        f_approx = f
    elseif downsample_size == :default
        f_approx = @lift downsample($f)
        @debug "Downsampled to $(size(f_approx[]))"
    else
        f_approx = @lift downsample($f, approx_size=downsample_size)
        @debug "Downsampled to $(size(f_approx[]))"
    end

    if domain_discretization(typeof(f[])) isa LatticeGrid
        plt = fieldplot!(ax, f_approx; kwargs...)
    else
        plt = scattervariable!(ax, f_approx; kwargs...)
    end

    if is2D && cbar_orientation == :vertical
        Colorbar(figurepos[1,2], plt;
            width = 20,
            tellheight = false,
            label = cbar_label
        )
    elseif is2D
        Colorbar(figurepos[1,2], plt;
            width = 20,
            vertical = false, flipaxis = false,
            tellheight = true,
            label = cbar_label
        )
    else
        if hasunit(first_f)
            clims = @lift extrema(norm.(ustrip($f)))
        else
            clims = @lift extrema(norm.($f))
        end
        Colorbar(figurepos[1,2],
            width = 20,
            tellwidth = true,
            colormap = :jet1,
            limits = clims,
            label = cbar_label
        )
    end

    if saveplot
        saveplot && save(filename, fig.scene)
    end

    return fig
end
