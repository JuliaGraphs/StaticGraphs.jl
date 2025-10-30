module StaticGraphsJLD2Ext

using JLD2
using StaticGraphs

function StaticGraphs.savesg(fn::AbstractString, g::StaticGraph)
    f_ind = g.f_ind
    f_vec = g.f_vec
    @save fn f_vec f_ind
    return 1
end

function StaticGraphs.savesg(fn::AbstractString, g::StaticDiGraph)
    f_ind = g.f_ind
    f_vec = g.f_vec
    b_ind = g.b_ind
    b_vec = g.b_vec
    @save fn f_vec f_ind b_vec b_ind
    return 1
end

function StaticGraphs.loadsg(fn::AbstractString, ::SGFormat)
    @load fn f_vec f_ind
    return StaticGraph(f_vec, f_ind)
end

function StaticGraphs.loadsg(fn::AbstractString, ::SDGFormat)
    @load fn f_vec f_ind b_vec b_ind
    return StaticDiGraph(f_vec, f_ind, b_vec, b_ind)
end

end