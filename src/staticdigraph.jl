"""
    StaticDiGraph{T, U}

A type representing a static directed graph.
"""
struct StaticDiGraph{T<:Integer, U<:Integer} <: AbstractStaticGraph{T, U}
    f_vec::Vector{T}
    f_ind::Vector{U}
    b_vec::Vector{T}
    b_ind::Vector{U}
end

@inline function _bvrange(g::StaticDiGraph, s)
    @inbounds r_start = g.b_ind[s]
    @inbounds r_end = g.b_ind[s + 1] - 1
    return r_start:r_end
end

@inline function badj(g::StaticDiGraph, s)
    r = _bvrange(g, s)
    return view(g.b_vec, r)
end

ne(g::StaticDiGraph{T, U}) where T where U = U(length(g.f_vec))

# sorted src, dst vectors for forward and backward edgelists.
function StaticDiGraph(n_v, f_ss::AbstractVector, f_ds::AbstractVector, b_ss::AbstractVector, b_ds::AbstractVector)
    length(f_ss) == length(f_ds) == length(b_ss) == length(b_ds) || error("source and destination vectors must be equal length")
    (n_v == 0 || length(f_ss) == 0) && return StaticDiGraph(UInt8[], UInt8[1], UInt8[], UInt8[1])
    f_ind = [searchsortedfirst(f_ss, x) for x in 1:n_v]
    push!(f_ind, length(f_ss)+1)
    b_ind = [searchsortedfirst(b_ss, x) for x in 1:n_v]
    push!(b_ind, length(b_ss)+1)
    T = mintype(maximum(f_ds))
    U = mintype(f_ind[end])
    return StaticDiGraph{T, U}(
        convert(Vector{T}, f_ds), 
        convert(Vector{U}, f_ind), 
        convert(Vector{T}, b_ds),
        convert(Vector{U}, b_ind)
    )
end

# sorted src, dst tuples for forward and backward
function StaticDiGraph(n_v, f_sd::Vector{Tuple{T, T}}, b_sd::Vector{Tuple{T, T}}) where T <: Integer
    f_ss = [x[1] for x in f_sd]
    f_ds = [x[2] for x in f_sd]
    b_ss = [x[1] for x in b_sd]
    b_ds = [x[2] for x in b_sd]

    StaticDiGraph(n_v, f_ss, f_ds, b_ss, b_ds)
end

function StaticDiGraph(g::LightGraphs.SimpleGraphs.SimpleDiGraph)
    ne(g) == 0 && return StaticDiGraph(nv(g), Array{Tuple{UInt8, UInt8},1}(), Array{Tuple{UInt8, UInt8},1}())
    f_sd = [Tuple(e) for e in edges(g)]
    b_sd = sort([Tuple(reverse(e)) for e in edges(g)])

    StaticDiGraph(nv(g), f_sd, b_sd)
end

function StaticDiGraph{T, U}(s::StaticDiGraph) where T <: Integer where U <: Integer
    new_fvec = T.(s.f_vec)
    new_find = U.(s.f_ind)
    new_bvec = T.(s.b_vec)
    new_bind = U.(s.b_ind)
    return StaticDiGraph(new_fvec, new_find, new_bvec, new_bind)
end


#
==(g::StaticDiGraph, h::StaticDiGraph) = g.f_vec == h.f_vec && g.f_ind == h.f_ind && g.b_vec == h.b_vec && g.b_ind == h.b_ind

degree(g::StaticDiGraph, v::Integer) = indegree(g, v) + outdegree(g, v)
degree(g::StaticDiGraph) = [degree(g, v) for v in vertices(g)]
indegree(g::StaticDiGraph, v::Integer) = length(_bvrange(g, v))
indegree(g::StaticDiGraph) = [indegree(g, v) for v in vertices(g)]
outdegree(g::StaticDiGraph, v::Integer) = length(_fvrange(g, v))
outdegree(g::StaticDiGraph) = [outdegree(g, v) for v in vertices(g)]


"""
    is_directed(g)

Return `true` if `g` is a directed graph.
"""
is_directed(::Type{StaticDiGraph}) = true
is_directed(::Type{StaticDiGraph{T, U}}) where T where U = true
is_directed(g::StaticDiGraph) = true

reverse(g::StaticDiGraph) = StaticDiGraph(copy(g.b_vec), copy(g.b_ind), copy(g.f_vec), copy(g.f_ind))