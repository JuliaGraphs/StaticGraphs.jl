

"""
    StaticGraph{T, U}

A type representing an undirected static graph.
"""
struct StaticGraph{T<:Integer, U<:Integer} <: AbstractStaticGraph{T, U}
    f_vec::Vector{T}
    f_ind::Vector{U}
end

# sorted src, dst vectors
# note: this requires reverse edges included in the sorted vector.  
function StaticGraph(nv::I, ss::AbstractVector, ds::AbstractVector) where {I<:Integer}
    length(ss) != length(ds) && error("source and destination vectors must be equal length")
    (nv == 0 || length(ss) == 0) && return StaticGraph(UInt8[], UInt8[1])
    f_ind = [searchsortedfirst(ss, x) for x in 1:n_v]
    push!(f_ind, length(ss)+1)
    T = mintype(ds)
    U = mintype(f_ind)
    return StaticGraph{T, U}(convert(Vector{T},ds), convert(Vector{U}, f_ind))
end

# sorted src, dst tuples
function StaticGraph(n_v, sd::Vector{Tuple{T, T}}) where T <: Integer
    ss = [x[1] for x in sd]
    ds = [x[2] for x in sd]
    return StaticGraph(n_v, ss, ds)
end

function StaticGraph(g::LightGraphs.SimpleGraphs.SimpleGraph)
    sd1 = [Tuple(e) for e in edges(g)]
    ds1 = [Tuple(reverse(e)) for e in edges(g)]
    sd = sort(vcat(sd1, ds1))
    return StaticGraph(nv(g), sd)
end

function StaticGraph()
    return StaticGraph(UInt8[], UInt8[1])
end

badj(g::StaticGraph, s) = fadj(g, s)

ne(g::StaticGraph{T, U}) where T where U = U(length(g.f_vec) ÷ 2)

function has_edge(g::StaticGraph, e::StaticGraphEdge)
    u, v = Tuple(e)
    (u > nv(g) || v > nv(g)) && return false
    if degree(g, u) > degree(g, v)
        u, v = v, u
    end
    return insorted(v, fadj(g, u))
end

function in(e::StaticGraphEdge, g::StaticGraph)
    u, v = Tuple(e)
    (u > nv(g) || v > nv(g)) && return false
    if degree(g, u) > degree(g, v)
        u, v = v, u
    end
    return insorted(v, fadj(g, u))
end

==(g::StaticGraph, h::StaticGraph) = g.f_vec == h.f_vec && g.f_ind == h.f_ind

degree(g::StaticGraph{T, U}, v::Integer) where T where U = T(length(_fvrange(g, v)))
degree(g::StaticGraph) = [degree(g, v) for v in vertices(g)]
indegree(g::StaticGraph, v::Integer) = degree(g, v)
indegree(g::StaticGraph) = degree(g)
outdegree(g::StaticGraph, v::Integer) = degree(g, v)
outdegree(g::StaticGraph) = degree(g)


"""
    is_directed(g)

Return `true` if `g` is a directed graph.
"""
is_directed(::Type{StaticGraph}) = false
is_directed(::Type{StaticGraph{T, U}}) where T where U = false
is_directed(g::StaticGraph) = false
