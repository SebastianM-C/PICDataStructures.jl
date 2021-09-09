using PICDataStructures, Test
using LaserTypes
using StaticArrays
using UnitfulAtomic
using PhysicalConstants.CODATA2018: c_0

λ = 15105.659329029153
c = austrip(c_0)
m = 2
p = 2
a₀ = 2.0
w₀ = 75 * λ

laser = setup_laser(LaguerreGaussLaser, :atomic;
    λ,
    m,
    p,
    a₀,
    w₀,
    profile = GaussProfile,
    τ = 10λ/(2π*c), z₀ = 0.
)

x_grid = y_grid = z_grid = -30:30

grid = SparseAxisGrid(x_grid, y_grid, y_grid)

t = 0.

electricfield = vectorfield(grid) do (x,y,z)
    r = SVector{3}(x, y, z).*w₀
    E(r, t, laser)
end

@test ndims(electricfield) == 3

E_slice = selectdim(electricfield, :z, 0.)

using CairoMakie

plotdata(E_slice)
