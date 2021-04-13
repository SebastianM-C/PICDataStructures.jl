function LinearAlgebra.norm(field::T) where T<:AbstractPICDataStructure
    data = unwrapdata(field)
    grid = getdomain(field)

    scalar_from(T)(norm.(data), grid)
end

function LinearAlgebra.cross(a::T, b::T) where T <: AbstractPICDataStructure
    @assert size(a) == size(b)
    @assert scalarness(T) === VectorQuantity()
    @assert propertynames(a) == propertynames(b)
    @assert dimensionality(a) == dimensionality(b) == 3 "The cross product is only defined in 3D"
    x_data = @. a.y * b.z - a.z * b.y
    y_data = @. a.z * b.x - a.x * b.z
    z_data = @. a.x * b.y - a.y * b.x

    data = StructArray((x_data, y_data, z_data); names=propertynames(a))
    parameterless_type(T)(data, getdomain(a))
end
