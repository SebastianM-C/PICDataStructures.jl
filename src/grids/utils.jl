"""
    autoname(N)

Given a `N` generate a tuple of length N with :x,:y,:z or :x1,...:xn
"""
function autonames(N)
    if N == 1
        (:x,)
    elseif N == 2
        (:x, :y)
    elseif N == 3
        (:x, :y, :z)
    else
        ntuple(N) do i
            Symbol("x$i")
        end
    end
end

function replace_default_names(names, N)
    if names == :auto
        autonames(N)
    else
        names
    end
end


"""
    axisnames(grid::AbstractGrid; include_units=true)

Get the names of the axis of the input `grid`.
In the case of Unitful quantities, they can be excluded by setting `include_units` to `false`.
"""
function axisnames(grid::AbstractGrid; include_units=true)
    names = string.(propertynames(grid))
    if include_units && hasunits(grid)
        units = unitname.(grid)
        string.(names, (" (",), units, (")",))
    else
        names
    end
end
