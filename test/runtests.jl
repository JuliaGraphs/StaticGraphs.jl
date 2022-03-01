using StaticGraphs
using Graphs
using Graphs.SimpleGraphs
using Test

const testdir = dirname(@__FILE__)

    
@testset "StaticGraphs" begin

    hu = loadgraph(joinpath(testdir, "testdata", "house-uint8.jsg"), SGFormat())
    dhu = loadgraph(joinpath(testdir, "testdata", "pathdg-uint8.jsg"), SDGFormat())

    @testset "staticgraph" begin
        @test sprint(show, StaticGraph(Graph())) == "{0, 0} undirected simple static {UInt8, UInt8} graph"
        g = smallgraph(:house)
        gc = complement(g)
        gu = squash(g)
        sg = StaticGraph(g)
        sgc = complement(sg)
        sgu = StaticGraph(gu)
        gempty = StaticGraph()
        gdempty = StaticDiGraph()
        @test eltype(StaticGraph{UInt128, UInt128}(sgu)) == UInt128
        @test sprint(show, sg) == "{5, 6} undirected simple static {UInt8, UInt8} graph"
        @test sprint(show, sgc) == "{5, 4} undirected simple static {UInt8, UInt8} graph"
        @test sprint(show, sgu) == "{5, 6} undirected simple static {UInt8, UInt8} graph"
        function testfn(fn, args...)
            @inferred(fn(hu, args...)) ==
            @inferred(fn(sg, args...)) ==
            @inferred(fn(sgu, args...)) ==
            fn(g, args...)
            @inferred(fn(sgc, args...)) ==
            fn(gc, args...)
        end
        @test hu == sg == sgu
        @test sgc == StaticGraph(gc)
        @test @inferred eltype(hu) == UInt8
        @test testfn(ne)
        @test testfn(nv)
        @test testfn(inneighbors, 1)
        @test testfn(outneighbors, 1)
        @test testfn(vertices)
        @test testfn(degree)
        @test testfn(degree, 1)
        @test testfn(indegree)
        @test testfn(indegree, 1)
        @test testfn(outdegree)
        @test testfn(outdegree, 1)

        @test @inferred has_edge(hu, 1, 3)
        @test @inferred has_edge(hu, 3, 1)
        @test @inferred !has_edge(hu, 2, 3)
        @test @inferred !has_edge(hu, 3, 2)
        @test @inferred !has_edge(hu, 1, 10)
        @test @inferred has_vertex(hu, 1)
        @test @inferred !has_vertex(hu, 10)
        @test @inferred !is_directed(hu)
        @test @inferred !is_directed(StaticGraph)
        @test @inferred collect(edges(hu)) == collect(edges(sg))
        @test @inferred StaticGraphs.fadj(hu) == [StaticGraphs.fadj(hu, x) for x in vertices(hu)]
        @test @inferred StaticGraphs.badj(hu) == StaticGraphs.fadj(hu)

        (g1, m1) = @inferred induced_subgraph(hu, [3,2,1])
        g2 = @inferred hu[3:-1:1]
        @test g1 == g2
        @test m1 == [3,2,1]

        z = @inferred(adjacency_matrix(hu, Bool, dir=:out))
        @test z[1,2]
        @test !z[1,4]
        @test z == adjacency_matrix(hu, Bool, dir=:in) == adjacency_matrix(hu, Bool, dir=:both)

        # empty constructors
        @test nv(gempty) === 0x00
        @test typeof(Graphs.nv(gempty)) == UInt8
        @test length(Graphs.edges(gempty)) === 0x00
        @test nv(gdempty) === 0x00
        @test length(Graphs.edges(gdempty)) === 0x00

    end # staticgraph

    @testset "staticdigraph" begin
        @test sprint(show, StaticDiGraph(DiGraph())) == "{0, 0} directed simple static {UInt8, UInt8} graph"
        dg = path_digraph(5)
        dgc = complement(dg)
        dgu = squash(dg)
        dsg = StaticDiGraph(dg)
        dsgc = complement(dsg)
        dsgu = StaticDiGraph(dgu)
        @test eltype(StaticDiGraph{UInt128, UInt128}(dsgu)) == UInt128
        @test sprint(show, dsg) == "{5, 4} directed simple static {UInt8, UInt8} graph"
        @test sprint(show, dsgc) == "{5, 16} directed simple static {UInt8, UInt8} graph"
        @test sprint(show, dsgu) == "{5, 4} directed simple static {UInt8, UInt8} graph"
        dhu = loadgraph(joinpath(testdir, "testdata", "pathdg-uint8.jsg"), SDGFormat())
        function dtestfn(fn, args...)
            @inferred(fn(dhu, args...)) ==
            @inferred(fn(dsg, args...)) ==
            @inferred(fn(dsgu, args...)) ==
            fn(dg, args...)
            @inferred(fn(dsgc, args...)) ==
            fn(dgc, args...)
        end

        @test dhu == dsg == dsgu
        @test dsgc == StaticDiGraph(dgc)
        @test @inferred eltype(dhu) == UInt8
        @test dtestfn(ne)
        @test dtestfn(nv)
        @test dtestfn(inneighbors, 1)
        @test dtestfn(outneighbors, 1)
        @test dtestfn(vertices)
        @test dtestfn(degree)
        @test dtestfn(degree, 1)
        @test dtestfn(indegree)
        @test dtestfn(indegree, 1)
        @test dtestfn(outdegree)
        @test dtestfn(outdegree, 1)

        @test @inferred has_edge(dhu, 1, 2)
        @test @inferred !has_edge(dhu, 2, 1)
        @test @inferred !has_edge(dhu, 1, 10)
        @test @inferred has_vertex(dhu, 1)
        @test @inferred !has_vertex(dhu, 10)
        @test @inferred is_directed(dhu)
        @test @inferred is_directed(StaticDiGraph)
        @test @inferred collect(edges(dhu)) == collect(edges(dsg))
        @test @inferred StaticGraphs.fadj(dhu) == [StaticGraphs.fadj(dhu, x) for x in vertices(dhu)]
        @test @inferred StaticGraphs.badj(dhu) == [StaticGraphs.badj(dhu, x) for x in vertices(dhu)]

        (g1, m1) = @inferred induced_subgraph(dhu, [3,2,1])
        g2 = @inferred dhu[3:-1:1]
        @test g1 == g2
        @test m1 == [3,2,1]

        z = @inferred(adjacency_matrix(dhu, Bool, dir=:out))
        @test z[1,2]
        @test !z[2,1]
        z = @inferred(adjacency_matrix(dhu, Bool, dir=:in))
        @test z[2,1]
        @test !z[1,2]
        @test_logs (:warn, r".*") adjacency_matrix(dhu, Bool, dir=:both) == adjacency_matrix(dhu, Bool)

    end # staticdigraph

    @testset "utils" begin
        @test StaticGraphs.mintype(BigInt(1e100)) == BigInt
    end # utils

    @testset "persistence" begin
        function writegraphs(f, fio)
            @test savegraph(f, hu) == 1
            @test savegraph(f, dhu) == 1
        end
        mktemp(writegraphs)
    end

end # StaticGraphs
