# StaticGraphs are binary files with the following format:
# sizeof(T), sizeU, f_vec, 0, f_ind
# StaticDiGraphs have the following format:
# bits in T, bits in U, f_vec, 0, f_ind, 0, b_vec, 0, b_ind

abstract type StaticGraphFormat <: AbstractGraphFormat end
struct SGFormat <: StaticGraphFormat end
struct SDGFormat <: StaticGraphFormat end

function savesg(fn::AbstractString, g::StaticGraph)
    f_ind = g.f_ind
    f_vec = g.f_vec
    @save fn f_vec f_ind
    return 1
end

function savesg(fn::AbstractString, g::StaticDiGraph)
    f_ind = g.f_ind
    f_vec = g.f_vec
    b_ind = g.b_ind
    b_vec = g.b_vec
    @save fn f_vec f_ind b_vec b_ind
    return 1
end

function loadsg(fn::AbstractString, ::SGFormat)
    @load fn f_vec f_ind
    return StaticGraph(f_vec, f_ind)
end

function loadsg(fn::AbstractString, ::SDGFormat)
    @load fn f_vec f_ind b_vec b_ind
    return StaticDiGraph(f_vec, f_ind, b_vec, b_ind)
end

loadgraph(fn::AbstractString, gname::String, s::StaticGraphFormat) = loadsg(fn, s)
savegraph(fn::AbstractString, g::AbstractStaticGraph) =  savesg(fn, g)