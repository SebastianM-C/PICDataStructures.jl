abstract type AbstractGrid{N,T,Names} end
struct LatticeGrid{N} end
struct ParticleGrid end

include("latticegrids.jl")
include("particlegrids.jl")
include("abstractgrid.jl")
include("utils.jl")
include("units.jl")
