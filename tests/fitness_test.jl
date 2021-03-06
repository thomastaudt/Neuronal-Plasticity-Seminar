@everywhere include("../src/EvoNet.jl")
ev = EvoNet
import EvoNet.@rec

EvoNet.optimize.@MakeMeta(MetaTopology, AbstractTopology)
EvoNet.optimize.@MakeMetaGen(MetaTopology, generate)

# create a random network
N = 20
generator = ev.SparseFRGenerator( N, topology = ev.MetaTopology(ev.AbstractTopology[ev.ErdösRenyiTopology(), ev.RingTopology()]) )

gopt = ev.GeneticOptimizer( ev.test_fitness_of_generator, ev.compare_fitness )

ev.init_population!(gopt, generator, 5)

for i = 1:25
  ev.step!(gopt)
  ev.save_evolution("genes.dat", gopt)
end

