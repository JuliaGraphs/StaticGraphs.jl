# StaticGraphs are binary files with the following format:
# sizeof(T), sizeU, f_vec, 0, f_ind
# StaticDiGraphs have the following format:
# bits in T, bits in U, f_vec, 0, f_ind, 0, b_vec, 0, b_ind

abstract type StaticGraphFormat <: AbstractGraphFormat end
struct SGFormat <: StaticGraphFormat end
struct SDGFormat <: StaticGraphFormat end

function loadsg(args...)
    error("In order to load static graphs from binary files, you need to load the JLD2.jl \
    package")
end

function savesg(args...)
    error("In order to save static graphs to binary files, you need to load the JLD2.jl \
    package")
end

loadgraph(fn::AbstractString, gname::String, s::StaticGraphFormat) = loadsg(fn, s)
savegraph(fn::AbstractString, g::AbstractStaticGraph) = savesg(fn, g)