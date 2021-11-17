function LinearAlgebra.cross(a::T1, b::T2) where {T1 <: AbstractPICDataStructure, T2 <: AbstractPICDataStructure}
    @assert size(a) == size(b)
    @assert scalarness(T1) === scalarness(T2) === VectorQuantity() "The cross product is only defined for Vector quantities"
    @assert propertynames(a) == propertynames(b)
    @assert dimensionality(a) == dimensionality(b) == 3 "The cross product is only defined in 3D"

    x_data = @. a.y * b.z - a.z * b.y
    y_data = @. a.z * b.x - a.x * b.z
    z_data = @. a.x * b.y - a.y * b.x

    data = StructArray((x_data, y_data, z_data); names=propertynames(a))
    grid = getdomain(a)
    name = nameof(a) * " × " * nameof(b)
    newstruct(a, data, grid; name)
end

# special case for r × p
function LinearAlgebra.cross(r::ParticlePositions, p::T) where {T <: AbstractPICDataStructure}
    @assert r == getdomain(p) "The position vector is incompatible"
    @assert dimensionality(r) == dimensionality(p) == 3 "The cross product is only defined in 3D"

    x_data = @. r.y * p.z - r.z * p.y
    y_data = @. r.z * p.x - r.x * p.z
    z_data = @. r.x * p.y - r.y * p.x

    data = StructArray((x_data, y_data, z_data); names=propertynames(r))
    name = "r × " * nameof(p)
    newstruct(p, data, r; name)
end
