# StructJuMP
The StructJuMP package provides a scalable algebraic modeling framework for block structured optimization models in Julia. StructJuMP was originally known as StochJuMP, and tailored specifically towards two-stage stochastic optimization problems. StructJuMP.jl is an extension of the [JuMP.jl](https://github.com/JuliaOpt/JuMP.jl) package, which is as fast as [AMPL](http://ampl.com) and faster than any other modeling tools such as [GAMS](http://www.gams.com) and [Pyomo](http://www.pyomo.org) (see [this](http://arxiv.org/pdf/1312.1431.pdf)).


##Nonlinear solvers for StructJuMP
The nonlinear StructJuMP models can be solved by either parallel or serial optimizaton solvers, such as PIPS-NLP or Ipopt. [PIPS-NLP](https://github.com/Argonne-National-Laboratory/PIPS) is an extension to PIPS that parallelizes the solving algorithm for nonlinear programming problems using *Schur complement* approach. [Ipopt](https://projects.coin-or.org/Ipopt) is an Interior point optimization solver for finding local solution of large-scale nonlinear optimization problems. In the later case, modeller can still take advantage of StructJuMP to model the problem using its structure, and to solve the problem using more matured (or robust) solvers. The corresponding solver interface implementations for PIPS-NLP and Ipopt are located at [StructJuMPSolverInterface](https://github.com/fqiang/StructJuMPSolverInterface.jl). 


##Installation
1. Install Ipopt solver:
 
 `julia> Pkg.add("Ipopt")`
2. Install StructJuMPSolverInterface:
 
 `julia> Pkg.clone("https://github.com/Argonne-National-Laboratory/StructJuMPSolverInterface.jl")`
3. Install and build PIPS-NLP solver by following its [installation instruction](https://github.com/Argonne-National-Laboratory/PIPS). 
4. Setting environment variables `PIPS_NLP_PAR_SHARED_LIB` and `PIPS_NLP_SHARED_LIB` to the location of the parallel and serial shared Libraries correspondingly. 
 
 **Note:** the shared libraries are named `libparpipsnlp.so|.dylib` and `libpipsnlp.so|.dylib` after building PIPS-NLP.


##An example
```julia
using StructJuMP, JuMP

numScen = 2
m = StructuredModel(num_scenarios=numScen)
@variable(m, x[1:2])
@NLconstraint(m, x[1] + x[2] == 100)
@NLobjective(m, Min, x[1]^2 + x[2]^2 + x[1]*x[2])

for i in 1:numScen
    bl = StructuredModel(parent=m, id=i)
    @variable(bl, y[1:2])
    @NLconstraint(bl, x[1] + y[1]+y[2] ≥  0)
    @NLconstraint(bl, x[2] + y[1]+y[2] ≤ 50)
    @NLobjective(bl, Min, y[1]^2 + y[2]^2 + y[1]*y[2])
end
```
The above example builds a two level structured model `m` with 2 scanarios. Then this model can be solved by calling `solve` function with a solver that implements the StructJuMPSolverInterface. 
```julia
solve(m, solver="PipsNlp") #solving using parallel PIPS-NLP solver
solve(m, solver="PipsNlpSerial") #solving using serial PIPS-NLP solver
solve(m, solver="Ipopt") #solving using serial Ipopt solver
```

## Known Limitation
* If a constraint declared at the sub-problem uses variable from the parent level, it has to be add using @NLconstraint (instead of @constraint). 
