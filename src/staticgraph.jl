

"""
    StaticGraph{T, U}

A type representing an undirected static graph.
"""
struct StaticGraph{T<:Integer} <: AbstractStaticGraph
    f_vec::Vector{T}
    f_ind::Vector{T}
end

badj(g::StaticGraph, s) = fadj(g, s)

ne(g::StaticGraph) = length(g.f_vec) ÷ 2


# sorted src, dst vectors
# note: this requires reverse edges included in the sorted vector.  
function StaticGraph(n_v, ss::Vector{T}, ds::Vector{T}) where T <: Integer
    length(ss) != length(ds) && error("source and destination vectors must be equal length")
    (n_v == 0 || length(ss) == 0) && return StaticGraph(T[], T[1])
    f_ind = [searchsortedfirst(ss, x) for x in 1:n_v]
    push!(f_ind, length(ss)+1)
    return StaticGraph{T}(ds, f_ind)
end

# sorted src, dst tuples
function StaticGraph(n_v, sd::Vector{Tuple{T, T}}) where T <: Integer
    ss = [x[1] for x in sd]
    ds = [x[2] for x in sd]
    StaticGraph(n_v, ss, ds)
end

function StaticGraph(g::LightGraphs.SimpleGraphs.SimpleGraph)
    sd1 = [Tuple(e) for e in edges(g)]
    ds1 = [Tuple(reverse(e)) for e in edges(g)]

    sd = sort(vcat(sd1, ds1))
    StaticGraph(nv(g), sd)
end

==(g::StaticGraph, h::StaticGraph) = g.f_vec == h.f_vec && g.f_ind == h.f_ind

degree(g::StaticGraph, v::Integer) = length(_fvrange(g, v))
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
is_directed(::Type{StaticGraph{T}}) where T = false
is_directed(g::StaticGraph) = false