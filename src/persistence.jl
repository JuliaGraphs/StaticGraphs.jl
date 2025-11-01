# StaticGraphs are binary files with the following format:
# sizeof(T), sizeU, f_vec, 0, f_ind
# StaticDiGraphs have the following format:
# bits in T, bits in U, f_vec, 0, f_ind, 0, b_vec, 0, b_ind

abstract type StaticGraphFormat <: AbstractGraphFormat end
struct SGFormat <: StaticGraphFormat end
struct SDGFormat <: StaticGraphFormat end

function loadsg end
function savesg end

loadgraph(fn::AbstractString, gname::String, s::StaticGraphFormat) = loadsg(fn, s)
savegraph(fn::AbstractString, g::AbstractStaticGraph) = savesg(fn, g)