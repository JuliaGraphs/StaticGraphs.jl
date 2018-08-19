struct UnsafeVectorView{T,U} <: AbstractVector{T}
    offset::U
    len::U
    ptr::Ptr{T}
end

@inline UnsafeVectorView(parent::Union{Vector, Base.FastContiguousSubArray}, range::UnitRange) = UnsafeVectorView(start(range) - 1, length(range), pointer(parent))
@inline Base.size(v::UnsafeVectorView) = (v.len,)
@inline Base.getindex(v::UnsafeVectorView, idx) = unsafe_load(v.ptr, idx + v.offset)
@inline Base.setindex!(v::UnsafeVectorView, value, idx) = unsafe_store!(v.ptr, value, idx + v.offset)
@inline Base.length(v::UnsafeVectorView) = v.len
Base.IndexStyle(::Type{V}) where {V <: UnsafeVectorView} = IndexLinear()

"""
UnsafeVectorView only works for isbits types. For other types, we're already
allocating lots of memory elsewhere, so creating a new SubArray is fine.
This function looks type-unstable, but the isbits(T) test can be evaluated
by the compiler, so the result is actually type-stable.
From https://github.com/rdeits/NNLS.jl/blob/0a9bf56774595b5735bc738723bd3cb94138c5bd/src/NNLS.jl#L218.
"""
@inline function fastview(parent::Union{Vector{T}, Base.FastContiguousSubArray{T}}, range::UnitRange) where T
    if isbits(T)
        UnsafeVectorView(parent, range)
    else
        view(parent, range)
    end
end

"""
    mintype(v)

Returns the minimum integer type required to represent integer `v`.
"""
function mintype(v::T) where T <: Integer
    validtypes = [UInt8, UInt16, UInt32, UInt64, UInt128]
    for U in validtypes
        v <= typemax(U) && return U
    end
    return T
end

