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
- `downsample_size`: Thw approximate downsample size for the input data.
By default (`:default`), it uses the heuristic values in [`downsample`](@ref).
If you want to avoid downsampling the data, use `nothing`.
Otherwise, the argument is the approximate maiximun size along any direction.
- `cbar_orientation`: The orientation of the attached `Colorbar`. By default is `:vertical`.
- `cbar_label`: The `Colorbar` label. Empty (`""`) by default.
- `saveplot`: Whether to save the plot or not. Default is `false`.
- `filename`: The filename to use if saving the plot.

Any additional Keyword arguments are passed to the internal plotting function
([`fieldplot`](@ref) or [`scattervariable`](@ref)). If you specify an `axis` keyword argument
using the standard Makie `NamedTuple` syntax, you can pass custom axis keywords,
such as `axis=(xticks=LinearTicks(10),)`.
"""
plotdata(f::AbstractPICDataStructure; kwargs...) = plotdata(Observable(f); kwargs...)

function plotdata(f::Observable;
    fig = Figure(),
    figurepos = fig[1,1],
    xlabel = :auto,
    ylabel = :auto,
    zlabel = :auto,
    downsample_size = :default,
    aspect_ratio = :default,
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
            ylabel = ylabel == :auto ? nameof(first_f) : ylabel
            aspect = aspect_ratio == :default ? AxisAspect(1) : aspect_ratio
        else
            _xlabel, _ylabel = axisnames(first_f)
            xlabel = xlabel == :auto ? _xlabel : xlabel
            ylabel = ylabel == :auto ? _ylabel : ylabel
            aspect = aspect_ratio == :default ? DataAspect() : aspect_ratio
        end

        if haskey(kwargs, :axis)
            ax = Axis(figurepos[1, 1];
                xlabel, ylabel,
                aspect,
                kwargs[:axis]...
            )
        else
            ax = Axis(figurepos[1, 1];
                xlabel, ylabel,
                aspect
            )
        end
    else
        _xlabel, _ylabel, _zlabel = axisnames(first_f)
        xlabel = xlabel == :auto ? _xlabel : xlabel
        ylabel = ylabel == :auto ? _ylabel : ylabel
        zlabel = zlabel == :auto ? _zlabel : zlabel

        ax = LScene(figurepos[1, 1];
            axis = (
                names = (axisnames = (xlabel, ylabel, zlabel),),
            ),
            scenekw = (camera = cam3d!, raw = false)
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

    if cbar_orientation == :vertical
        Colorbar(figurepos[1,2], plt;
            width = 20,
            tellheight = false,
            highclip = plt.highclip,
            lowclip = plt.lowclip,
            label = cbar_label
        )
    else
        Colorbar(figurepos[1,2], plt;
            width = 20,
            vertical = false, flipaxis = false,
            tellheight = true,
            highclip = plt.highclip,
            lowclip = plt.lowclip,
            label = cbar_label
        )
    end

    if saveplot
        saveplot && save(filename, fig.scene)
    end

    return fig
end
