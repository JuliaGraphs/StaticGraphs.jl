import Graphs.LinAlg: adjacency_matrix
import Graphs: induced_subgraph

adjacency_matrix(g::StaticGraph{I,U}, T::DataType; dir = :out!) where I<:Integer where U<:Integer =
    SparseMatrixCSC{T,I}(nv(g), nv(g), g.f_ind, g.f_vec, ones(T, ne(g)*2))

function adjacency_matrix(g::StaticDiGraph{I,U}, T::DataType; dir = :out) where I<:Integer where U<:Integer
    if dir == :in
        return SparseMatrixCSC{T,I}(nv(g), nv(g), g.f_ind, g.f_vec, ones(T, ne(g)))
    end
    z = SparseMatrixCSC{T,I}(nv(g), nv(g), g.b_ind, g.b_vec, ones(T, ne(g)))
    dir != :out && @warn("direction `$dir` not defined for adjacency matrices on StaticGraphs; defaulting to `out`")
    return z
end

# induced subgraphs preserve the eltypes of the vertices.
function induced_subgraph(g::StaticDiGraph{I, U}, vlist::AbstractVector{T}) where T <: Integer where I <: Integer where U<:Integer
    vlist_len = length(vlist)
    f_vec = Vector{I}()
    b_vec = Vector{I}()
    f_ind = Vector{U}([1])
    b_ind = Vector{U}([1])
    
    let vset = I.(vlist) # needed because of julialang/julia/ issue #15276
        sizehint!(f_ind, vlist_len+1)
        sizehint!(b_ind, vlist_len+1)
    
        vlist_len == length(vset) || throw(ArgumentError("Vertices in subgraph list must be unique"))
        fpos = 1
        bpos = 1
        @inbounds for v in vlist
            o = filter(x -> x in vset, outneighbors(g, v))
            i = filter(x -> x in vset, inneighbors(g, v))
        
            fpos += length(o)
            bpos += length(i)

            append!(f_vec, o)
            append!(b_vec, i)
            push!(f_ind, fpos)
            push!(b_ind, bpos)
        end
    end
    return StaticDiGraph(f_vec, f_ind, b_vec, b_ind), T.(vlist)
end

function induced_subgraph(g::StaticGraph{I, U}, vlist::AbstractVector{T}) where T <: Integer where I <: Integer where U<:Integer
    vlist_len = length(vlist)
    f_vec = Vector{I}()
    f_ind = Vector{U}([1])
    let vset = I.(vlist) # needed because of julialang/julia/ issue #15276
        sizehint!(f_ind, vlist_len + 1)
        vlist_len == length(vset) || throw(ArgumentError("Vertices in subgraph list must be unique"))
        fpos = 1
        for v in vlist
            o = filter(x -> x in vset, outneighbors(g, v))
            fpos += length(o)
            append!(f_vec, o)
            push!(f_ind, fpos)
        end
    end
    return StaticGraph(f_vec, f_ind), T.(vlist)
end
