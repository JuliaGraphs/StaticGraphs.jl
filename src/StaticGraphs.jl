module StaticGraphs

using LightGraphs

import Base:
    convert, eltype, show, ==, Pair, Tuple, in, copy, length, start, next, done, issubset, zero, one,
    size, getindex, setindex!, length, IndexStyle

import LightGraphs:
    _NI, _insert_and_dedup!, AbstractEdge, AbstractEdgeIter,
    src, dst, edgetype, nv, ne, vertices, edges, is_directed,
    has_vertex, has_edge, in_neighbors, out_neighbors,
    indegree, outdegree, degree, insorted,

    AbstractGraphFormat, loadgraph, savegraph

import LightGraphs.SimpleGraphs: 
    AbstractSimpleGraph, 
    fadj, 
    badj,
    SimpleEdge,
    AbstractSimpleEdge

export
    AbstractStaticGraph,
    StaticEdge,
    StaticGraph,
    StaticDiGraph,
    StaticDiGraphEdge,
    # weight,
    # weighttype,
    # get_weight,
    out_edges,
    in_edges,
    SGraph,
    SDiGraph,
    SGFormat,
    SDGFormat

include("utils.jl")

const StaticEdgeIter{G} = LightGraphs.SimpleGraphs.SimpleEdgeIter{G}
const AbstractStaticEdge = AbstractSimpleEdge
const StaticEdge = SimpleEdge

"""
    AbstractStaticGraph

An abstract type representing a simple graph structure.
AbstractStaticGraphs must have the following elements:
- weightmx::AbstractSparseMatrix{Real}
"""
abstract type AbstractStaticGraph <: AbstractSimpleGraph end

function show(io::IO, g::AbstractStaticGraph)
    if is_directed(g)
        dir = "directed"
    else
        dir = "undirected"
    end
    if nv(g) == 0
        print(io, "empty $dir simple static $(eltype(g)) graph")
    else
        print(io, "{$(nv(g)), $(ne(g))} $dir simple static $(eltype(g)) graph")
    end
end

@inline function _fvrange(g::AbstractStaticGraph, s::Integer)
    @inbounds r_start = g.f_ind[s]
    @inbounds r_end = g.f_ind[s + 1] - 1
    return r_start:r_end
end

@inline function fadj(g::AbstractStaticGraph, s::Integer)
    r = _fvrange(g, s)
    return fastview(g.f_vec, r)
end

nv(g::AbstractStaticGraph) = length(g.f_ind) - 1
vertices(g::AbstractStaticGraph) = one(eltype(g)):nv(g)
eltype(x::AbstractStaticGraph) = eltype(x.f_vec)

has_edge(g::AbstractStaticGraph, e::AbstractStaticEdge) =
    insorted(dst(e), neighbors(g, src(e)))

edgetype(g::AbstractStaticGraph) = StaticEdge
edges(g::AbstractStaticGraph) = StaticEdgeIter(g)

has_vertex(g::AbstractStaticGraph, v::Integer) = v in vertices(g)

out_neighbors(g::AbstractStaticGraph, v::Integer) = fadj(g, v)
in_neighbors(g::AbstractStaticGraph, v::Integer) = badj(g, v)

zero(g::T) where T<:AbstractStaticGraph = T()

copy(g::T) where T <: AbstractStaticGraph =  T(copy(g.f_vec), copy(g.f_ind))

const StaticGraphEdge = StaticEdge
const StaticDiGraphEdge = StaticEdge
include("staticgraph.jl")
include("staticdigraph.jl")
include("persistence.jl")

const SGraph = StaticGraph
const SDiGraph = StaticDiGraph

end # module
