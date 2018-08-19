function adjacency_matrix(g::StaticGraph)
    SparseMatrixCSC{Bool,UInt32}(nv(g), nv(g), g.f_ind, g.f_vec, ones(Bool, ne(g)*2))
end

function adjacency_matrix(g::StaticDiGraph)
    SparseMatrixCSC{Bool,UInt32}(nv(g), nv(g), g.f_ind, g.f_vec, ones(Bool, ne(g)))
end