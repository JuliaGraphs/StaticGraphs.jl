immutable UnsafeVectorView{T} <: AbstractVector{T}
    offset::Int
    len::Int
    ptr::Ptr{T}
end

@inline UnsafeVectorView(parent::Union{Vector, Base.FastContiguousSubArray}, range::UnitRange) = UnsafeVectorView(start(range) - 1, length(range), pointer(parent))
@inline Base.size(v::UnsafeVectorView) = (v.len,)
@inline Base.getindex(v::UnsafeVectorView, idx) = unsafe_load(v.ptr, idx + v.offset)
@inline Base.setindex!(v::UnsafeVectorView, value, idx) = unsafe_store!(v.ptr, value, idx + v.offset)
@inline Base.length(v::UnsafeVectorView) = v.len
Base.IndexStyle{V <: UnsafeVectorView}(::Type{V}) = IndexLinear()

"""
UnsafeVectorView only works for isbits types. For other types, we're already
allocating lots of memory elsewhere, so creating a new SubArray is fine.
This function looks type-unstable, but the isbits(T) test can be evaluated
by the compiler, so the result is actually type-stable.
From https://github.com/rdeits/NNLS.jl/blob/0a9bf56774595b5735bc738723bd3cb94138c5bd/src/NNLS.jl#L218.
"""
@inline function fastview{T}(parent::Union{Vector{T}, Base.FastContiguousSubArray{T}}, range::UnitRange)
    if isbits(T)
        UnsafeVectorView(parent, range)
    else
        view(parent, range)
    end
end

"""
    squashsorted(v)

Returns the sorted vector `v` converted to the smallest possible
integer type that can fit all values.

### Implementation Notes
`v` is assumed to be sorted.
"""
function squashsorted(v::AbstractVector)
    validtypes = [UInt8, UInt16, UInt32, UInt64, UInt128]
    l = v[end]
    for T in validtypes
        l < typemax(T) && return convert(Vector{T}, v)
    end
    return v
end

function mintype(v::AbstractVector)
    validtypes = [UInt8, UInt16, UInt32, UInt64, UInt128]
    l = v[end]
    for T in validtypes
        l < typemax(T) && return T
    end
    return eltype(v)
end

    
