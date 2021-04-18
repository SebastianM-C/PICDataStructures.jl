function LinearAlgebra.cross(a::T1, b::T2) where {T1 <: AbstractPICDataStructure, T2 <: AbstractPICDataStructure}
    @assert size(a) == size(b)
    @assert scalarness(T1) === scalarness(T2) === VectorQuantity() "The cross product is only defined for Vector quantities"
    @assert propertynames(a) == propertynames(b)
    @assert dimensionality(a) == dimensionality(b) == 3 "The cross product is only defined in 3D"

    x_data = @. a.y * b.z - a.z * b.y
    y_data = @. a.z * b.x - a.x * b.z
    z_data = @. a.x * b.y - a.y * b.x

    data = StructArray((x_data, y_data, z_data); names=propertynames(a))
    parameterless_type(T1)(data, getdomain(a))
end
