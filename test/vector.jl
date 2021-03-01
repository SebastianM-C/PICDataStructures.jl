using PICDataStructures, Test
using Unitful

grid = (0:0.01:1, 0:0.01:1)
data = [sin(x)*sin(y) for (x,y) in Iterators.product(grid...)]

f = ScalarField(data, grid)

vf = build_vector((f, f), (:x, :y))

@test isconcretetype(typeof(vf))
@test_broken vf.x == f

using LinearAlgebra
nvf = norm(vf)

@test scalarness(typeof(nvf)) === ScalarQuantity()
@test norm(vf[2,10]) == nvf[2,10]
