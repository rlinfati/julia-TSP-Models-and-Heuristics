# Julia TSP Mathematical Model and Heuristic Algorithm

This repository contains Julia code for solving the Traveling Salesman Problem (TSP) using both mathematical modeling and heuristic algorithms. It is intended for use as teaching material in an operational research course.

## Mathematical Model
The mathematical model of the TSP in this repository is formulated as a mixed-integer linear program (MILP) using the JuMP modeling language in Julia. The MILP model seeks to minimize the total distance traveled by the salesman subject to constraints that ensure each city is visited exactly once and that there are no subtours.

## Heuristic Algorithms
This repository includes several heuristic algorithms for finding initial solutions, improving solutions, and finding high-quality solutions efficiently:

### Finding Initial Solutions
Nearest neighbor algorithm: This is a simple greedy algorithm that selects the nearest unvisited city to the current city as the next city to visit.

### Improving Solutions
2-opt heuristic: This is a local search heuristic that iteratively removes two edges from the tour and reconnects them in a way that reduces the total distance traveled.

### Single Solution Metaheuristics

#### Tabu search algorithm
This is a metaheuristic algorithm that iteratively searches for a better solution to the TSP by randomly perturbing the current solution and keeping track of "tabu" moves that should not be made again in the near future.
#### Simulated annealing algorithm
This is a metaheuristic algorithm that iteratively searches for a better solution to the TSP by accepting moves that worsen the solution with some probability, which decreases over time.
#### Variable neighborhood search algorithm
This is a metaheuristic algorithm that iteratively searches for a better solution to the TSP by exploring different neighborhoods of the current solution and intensifying the search in promising neighborhoods.

### Population Metaheuristics
#### Genetic algorithm
This is a metaheuristic algorithm that maintains a population of solutions and evolves them over time using genetic operators such as mutation and crossover.
#### Ant colony optimization algorithm
This is a metaheuristic algorithm that iteratively searches for a better solution to the TSP by simulating the foraging behavior of ants and using pheromone trails to guide the search.

## Usage
To use this code, simply download or clone the repository and open the Pluto notebooks in the "notebooks" directory.
To see the executed Pluto notebooks, please visit https://rlinfati.github.io/julia-TSP-Models-and-Heuristics/.
