using JuMPStoch

m = StochasticModel()

n = 10
@defStochasticVar(m, x[1:n] >= 0)
@defStochasticVar(m, y[1:n] >= 0)
for i in 1:n
    @addConstraint(m, x[i] - y[i] <= i)
end

p = 3
q = 2
for s = 1:p
    bl = StochasticBlock(m, "level1-$s")
    @defStochasticVar(bl, z[1:n] >= 0)
    @addConstraint(bl, sum{z[i], i=1:n} == 1)
    for t = 1:q
        bll = StochasticBlock(m, "level2-$s,$t")
        @defStochasticVar(m, w[1:n] >= 0)
        @addConstraint(bll, sum{w[i], i=1:n; iseven(i)} == 1)
        parent = getStochastic(bll).parent
        @addConstraint(bll, sum{z[parent,i], i=1:n} >= sum{w[i], i=1:n})
    end
end
