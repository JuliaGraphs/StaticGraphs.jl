import LightGraphs.LinAlg: adjacency_matrix

adjacency_matrix(g::StaticGraph{I,U}, T::DataType; dir = :out) where I<:Integer where U<:Integer =
    SparseMatrixCSC{T,I}(nv(g), nv(g), g.f_ind, g.f_vec, ones(T, ne(g)*2))

function adjacency_matrix(g::StaticDiGraph{I,U}, T::DataType; dir = :out) where I<:Integer where U<:Integer
    if dir == :in
        return SparseMatrixCSC{T,I}(nv(g), nv(g), g.f_ind, g.f_vec, ones(T, ne(g)*2))
    end
    z = SparseMatrixCSC{T,I}(nv(g), nv(g), g.b_ind, g.b_vec, ones(T, ne(g)))
    dir != :out && @warn("direction `$dir` not defined for adjacency matrices on StaticGraphs; defaulting to `out`")
    return z
end
