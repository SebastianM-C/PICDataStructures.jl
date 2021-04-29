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

function broadcast_grid(f, arg, g::NTuple{N}) where N
    ntuple(N) do i
        f.(arg, g[i])
    end
end
