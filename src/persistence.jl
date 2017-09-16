# StaticGraphs are binary files with the following format:
# f_vec, 0, f_ind
# StaticDiGraphs have the following format:
# f_vec, 0, f_ind, 0, b_vec, 0, b_ind

abstract type StaticGraphFormat <: AbstractGraphFormat end
struct SGFormat{T<:Integer} <: StaticGraphFormat end
struct SDGFormat{T<:Integer} <: StaticGraphFormat end

SGFormat() = SGFormat{Int64}()
SGFormat(T::DataType) = SGFormat{T}()

SDGFormat() = SDGFormat{Int64}()
SDGFormat(T::DataType) = SDGFormat{T}()


function savesg(fn::AbstractString, g::StaticGraph, T::DataType)
    open(fn, "w+") do io
        arr = vcat(g.f_vec, [0], g.f_ind)
        v = Mmap.mmap(io, Vector{T}, length(arr))
        for i = 1:length(arr)
            @inbounds v[i] = arr[i]
        end
        Mmap.sync!(v)
    end
    return 1
end

function savesg(fn::AbstractString, g::StaticDiGraph, T::DataType)
    open(fn, "w+") do io
        farr = vcat(g.f_vec, [0], g.f_ind)
        barr = vcat(g.b_vec, [0], g.b_ind)
        arr = vcat(farr, [0], barr)
        v = Mmap.mmap(io, Vector{T}, length(arr))
        for i = 1:length(arr)
            @inbounds v[i] = arr[i]
        end
        Mmap.sync!(v)
    end
    return 1
end

function loadsg(fn::AbstractString, ::SGFormat{T}) where T <: Integer
    open(fn, "r") do io
        arr = Mmap.mmap(io, Vector{T})
        zeroind = findfirst(arr, 0)
        StaticGraph{T}(arr[1:zeroind-1], arr[zeroind+1:end])
    end
end

function loadsg(fn::AbstractString, ::SDGFormat{T}) where T <: Integer
    open(fn, "r") do io
        arr = Mmap.mmap(io, Vector{T})
        (z1, z2, z3) = findin(arr, 0)
        f_arr = fastview(arr, 1:(z1 - 1))
        f_ind = fastview(arr, (z1 + 1):(z2 - 1))
        b_arr = fastview(arr, (z2 + 1):(z3 - 1))
        b_ind = fastview(arr, (z3 + 1):length(arr))
        StaticDiGraph{T}(f_arr, f_ind, b_arr, b_ind)
    end
end

loadgraph(fn::AbstractString, gname::String, s::T) where T <: StaticGraphFormat = loadsg(fn, s)
savegraph(fn::AbstractString, g::AbstractStaticGraph, gname::String) = savegraph(fn, g)
savegraph(fn::AbstractString, g::AbstractStaticGraph) =  savesg(fn, g, eltype(g))