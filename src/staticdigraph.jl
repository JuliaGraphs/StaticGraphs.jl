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
    return fastview(g.b_vec, r)
end

ne(g::StaticDiGraph{T, U}) where T where U = U(length(g.f_vec))

# sorted src, dst vectors for forward and backward edgelists.
function StaticDiGraph(nvtx::I, f_ss::AbstractVector{F}, f_ds::AbstractVector{D}, b_ss::AbstractVector{B}, b_ds::AbstractVector{S}) where {I<:Integer,S<:Integer,D<:Integer,B<:Integer,F<:Integer}
    length(f_ss) == length(f_ds) == length(b_ss) == length(b_ds) || error("source and destination vectors must be equal length")
    (nvtx == 0 || length(f_ss) == 0) && return StaticDiGraph(UInt8[], UInt8[1], UInt8[], UInt8[1])
    f_ind = [searchsortedfirst(f_ss, x) for x in 1:nvtx]
    push!(f_ind, length(f_ss)+1)
    b_ind = [searchsortedfirst(b_ss, x) for x in 1:nvtx]
    push!(b_ind, length(b_ss)+1)
    T = mintype(f_ds)
    U = mintype(f_ind)
    return StaticDiGraph{T, U}(
        convert(Vector{T}, f_ds), 
        convert(Vector{U}, f_ind), 
        convert(Vector{T}, b_ds),
        convert(Vector{U}, b_ind)
    )
end

# sorted src, dst tuples for forward and backward
function StaticDiGraph(nvtx::I, f_sd::Vector{Tuple{T, T}}, b_sd::Vector{Tuple{T, T}}) where {T<:Integer,I<:Integer}
    f_ss = [x[1] for x in f_sd]
    f_ds = [x[2] for x in f_sd]
    b_ss = [x[1] for x in b_sd]
    b_ds = [x[2] for x in b_sd]

    return StaticDiGraph(nvtx, f_ss, f_ds, b_ss, b_ds)
end

function StaticDiGraph(g::LightGraphs.SimpleGraphs.SimpleDiGraph)
    f_sd = [Tuple(e) for e in edges(g)]
    b_sd = sort([Tuple(reverse(e)) for e in edges(g)])

    return StaticDiGraph(nv(g), f_sd, b_sd)
end

function StaticDiGraph()
    return StaticDiGraph(UInt8[], UInt8[1], UInt8[], UInt8[1])
end

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
is_directed(::Type{StaticDiGraph{T}}) where T = true
is_directed(g::StaticDiGraph) = true
