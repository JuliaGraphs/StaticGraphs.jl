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

    
