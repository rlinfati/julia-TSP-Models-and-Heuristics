### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 51bfede6-1436-11ec-0cc6-bfff507e0e99
begin
    import Pkg
    Pkg.UPDATED_REGISTRY_THIS_SESSION[] = true
    Pkg.activate()
    Pkg.add([
        Pkg.PackageSpec("Plots")
        Pkg.PackageSpec("PlutoUI")
    ])
    Pkg.status()
end

# ╔═╡ 06550f25-8997-406b-9617-aecd9efdaabc
using Plots

# ╔═╡ 557451e9-0f61-480c-be53-0a0e6af60068
using Random

# ╔═╡ 03fcd07b-99d5-4e2d-bc7f-9e00909139c6
using Statistics

# ╔═╡ a0ccec84-e98f-44fb-a7af-cf69e7d8200f
using PlutoUI

# ╔═╡ 93987a6f-06af-4fd3-9a58-e33b1a7293f1
include(joinpath(@__DIR__, "../200-Heuristic/100-function.jl"))

# ╔═╡ 58a0df0b-7c4f-40e2-b6da-d232d9d3e7e0
include(joinpath(@__DIR__, "../200-Heuristic/200-initial.jl"))

# ╔═╡ db63e9bf-5236-45ab-b8d0-8158c01787e7
md"""
# Traveling Salesman Problem (TSP)
[TSP en Wikipedia](https://en.wikipedia.org/wiki/Travelling_salesman_problem)
"""

# ╔═╡ c1b0733f-63d3-4e6a-9705-42bccb5d38de
md"""
## Operadores de cruzamiento
"""

# ╔═╡ ba80dace-0bdc-4239-a68c-0859f487ab45
function gaPMX(padre1::Array{Int,1}, padre2::Array{Int,1})
    n = length(padre1) - 1

    gen1 = rand(2:n-1)
    gen2 = rand(2:n-1)
    while gen1 == gen2
        gen2 = rand(2:n-1)
    end
    if gen1 > gen2
        gen1, gen2 = gen2, gen1
    end

    hijo1 = zero(padre1)
    hijo2 = zero(padre2)

    hijo1[gen1:gen2] = padre2[gen1:gen2]
    hijo2[gen1:gen2] = padre1[gen1:gen2]

    for i in vcat(1:gen1-1, gen2+1:n)
        in1 = findfirst(isequal(padre1[i]), hijo1)
        if in1 === nothing
            hijo1[i] = padre1[i]
        else
            tmpin = in1
            while tmpin !== nothing
                tmpin = findfirst(isequal(hijo2[in1]), hijo1)
                in1 = tmpin === nothing ? in1 : tmpin
            end
            hijo1[i] = padre1[in1]
        end

        in2 = findfirst(isequal(padre2[i]), hijo2)
        if in2 === nothing
            hijo2[i] = padre2[i]
        else
            tmpin = in2
            while tmpin !== nothing
                tmpin = findfirst(isequal(hijo1[in2]), hijo2)
                in2 = tmpin === nothing ? in2 : tmpin
            end
            hijo2[i] = padre2[in2]
        end
    end

    hijo1[end] = hijo1[1]
    hijo2[end] = hijo2[1]

    return hijo1, hijo2
end

# ╔═╡ c7c9a12f-f3ab-4251-888d-d1ac9b87aa60
md"""
## Operadores de Mutacion
"""

# ╔═╡ e44f264e-e87d-4498-b89a-cdd8519eddd1
function gaSWAP(ind::Array{Int,1})
    n = length(ind) - 1

    mutind = copy(ind)

    gen1 = rand(2:n)
    gen2 = rand(2:n)
    while gen1 == gen2
        gen2 = rand(2:n)
    end

    mutind[gen1], mutind[gen2] = mutind[gen2], mutind[gen1]
    return mutind
end

# ╔═╡ d049dd39-4736-4ff0-b2b0-981c61ee3296
md"""
## Operadores de Seleccion
"""

# ╔═╡ fab77d3b-203d-4033-bdd0-6ee1ff3cc572
function gaDuelo(fitness::Array{Float64,1}, spop::Int)
    nPoblacion = length(fitness)
    selected = falses(nPoblacion)

    while sum(selected) < spop
        player1 = rand(1:nPoblacion)
        player2 = rand(1:nPoblacion)
        while player1 == player2
            player2 = rand(1:nPoblacion)
        end

        sp = fitness[player1] + fitness[player2]
        if rand() < fitness[player1] / sp
            selected[player1] = true
            fitness[player1] = 0.0
        else
            selected[player2] = true
            fitness[player2] = 0.0
        end
    end

    return selected
end

# ╔═╡ bd777b54-0511-4dc0-8edf-29414ec4bdeb
function gaBestK(fitness::Array{Float64,1}, spop::Int)
    nPoblacion = length(fitness)
    selected = falses(nPoblacion)

    while sum(selected) < spop
        se = argmax(fitness)
        selected[se] = true
        fitness[se] = 0.0
    end

    return selected
end

# ╔═╡ 6ef09464-2e99-43c3-99e9-af732d04db80
md"""
## Genetic Algorithm
"""

# ╔═╡ 8c2906e8-9656-44d2-89c4-0a5c2061440f
function mhGA(dist::Array{Float64,2})
    n, _ = size(dist)

    nPoblacion = 3 * n
    nGeneraciones = 20 * n
    pCruzamiento::Float64 = 0.80
    pMutacion::Float64 = 0.05

    busqueda0 = [] # promedio ztour
    busqueda1 = [] # mejor    ztour
    mejortour = [0]

    Poblacion = [randperm(n) for _ in 1:nPoblacion]
    for ind in Poblacion
        push!(ind, ind[1])
    end

    for _ in 1:nGeneraciones
        while length(Poblacion) < 2 * nPoblacion
            padre1 = rand(Poblacion[1:nPoblacion])
            padre2 = rand(Poblacion[1:nPoblacion])
            while padre1 == padre2
                padre2 = rand(Poblacion[1:nPoblacion])
            end

            if rand() > pCruzamiento
                continue
            end
            hijo1, hijo2 = gaPMX(padre1, padre2)

            @assert tspDist(dist, hijo1) != Inf
            @assert tspDist(dist, hijo2) != Inf

            push!(Poblacion, hijo1)
            push!(Poblacion, hijo2)
        end

        for ind in Poblacion
            if rand() > pMutacion
                continue
            end
            mutind = gaSWAP(ind)

            @assert tspDist(dist, mutind) != Inf
            push!(Poblacion, mutind)
        end

        zt = [tspDist(dist, i) for i in Poblacion]
        push!(busqueda0, mean(zt))
        push!(busqueda1, minimum(zt))

        bestID = argmin(zt)
        if zt[bestID] < tspDist(dist, mejortour)
            mejortour = Poblacion[bestID]
        end

        fitness = mean(zt) ./ zt
        sel = gaBestK(fitness, floor(Int, nPoblacion / 5.0))
        newPob = unique(vcat([mejortour], Poblacion[sel]))
        while length(newPob) < nPoblacion
            sel = gaDuelo(fitness, nPoblacion - length(newPob))
            newPob = unique(vcat(newPob, Poblacion[sel]))
        end
        Poblacion = newPob
    end

    plot(busqueda0)
    plot!(busqueda1)
    savefig(joinpath(@__DIR__, "tsp-plot-GAz.png"))

    return mejortour
end

# ╔═╡ b03019d3-0270-45d8-ab5e-fcfb8d20dbc6
n = 7

# ╔═╡ 3f648c67-e281-406e-8953-28c6f138280c
# X, Y = tspXYRand(n)
# X, Y = tspXYCluster(n)
X, Y = tspXYRand(n)

# ╔═╡ 436ddb1e-5ea8-4cf5-9288-3c4cf4f744f9
# dist = distEuclidean(X, Y)
# dist = distManhattan(X, Y)	
# dist = distMaximum(X, Y)
# dist = distGeographical(X, Y)
dist = distEuclidean(X, Y)

# ╔═╡ e25019e0-3c89-4dc9-8adc-96900affe702
tourMH = mhGA(dist)

# ╔═╡ f5050494-1975-4558-9a1f-2a44b388b3dd
tspPlot(X, Y, tourMH)

# ╔═╡ 1e099701-6fd7-42d3-a76e-0077c4c8a174
PlutoUI.LocalResource(joinpath(@__DIR__, "tsp-plot-GAz.png"))

# ╔═╡ 630ddb7e-7dd1-4a1d-8d22-01748b0a4817
begin
    # using PlutoUI
    PlutoUI.TableOfContents()
end

# ╔═╡ Cell order:
# ╠═51bfede6-1436-11ec-0cc6-bfff507e0e99
# ╠═db63e9bf-5236-45ab-b8d0-8158c01787e7
# ╠═06550f25-8997-406b-9617-aecd9efdaabc
# ╠═557451e9-0f61-480c-be53-0a0e6af60068
# ╠═03fcd07b-99d5-4e2d-bc7f-9e00909139c6
# ╠═a0ccec84-e98f-44fb-a7af-cf69e7d8200f
# ╠═93987a6f-06af-4fd3-9a58-e33b1a7293f1
# ╠═58a0df0b-7c4f-40e2-b6da-d232d9d3e7e0
# ╠═c1b0733f-63d3-4e6a-9705-42bccb5d38de
# ╠═ba80dace-0bdc-4239-a68c-0859f487ab45
# ╠═c7c9a12f-f3ab-4251-888d-d1ac9b87aa60
# ╠═e44f264e-e87d-4498-b89a-cdd8519eddd1
# ╠═d049dd39-4736-4ff0-b2b0-981c61ee3296
# ╠═fab77d3b-203d-4033-bdd0-6ee1ff3cc572
# ╠═bd777b54-0511-4dc0-8edf-29414ec4bdeb
# ╠═6ef09464-2e99-43c3-99e9-af732d04db80
# ╠═8c2906e8-9656-44d2-89c4-0a5c2061440f
# ╠═b03019d3-0270-45d8-ab5e-fcfb8d20dbc6
# ╠═3f648c67-e281-406e-8953-28c6f138280c
# ╠═436ddb1e-5ea8-4cf5-9288-3c4cf4f744f9
# ╠═e25019e0-3c89-4dc9-8adc-96900affe702
# ╠═f5050494-1975-4558-9a1f-2a44b388b3dd
# ╠═1e099701-6fd7-42d3-a76e-0077c4c8a174
# ╠═630ddb7e-7dd1-4a1d-8d22-01748b0a4817
