include { crossProduct; filed; deliverables } from '../cross.nf'
include { instantiate; precompile; activate } from '../pkg.nf'

def julia_env = file(moduleDir/'julia_env')

params.dryRun = false
params.n_rounds = params.dryRun ? 1 : 5

def variables = [
    seed: 1..10,
    n_chains: [10, 20], 
]

workflow {
    compiled_env = instantiate(julia_env) | precompile
    configs = crossProduct(variables, params.dryRun)
    run_julia(compiled_env, configs) 
}

process run_julia {
    input:
        path julia_env 
        val config 
    """
    ${activate(julia_env)}

    # run your code
    using Pigeons 
    using CSV 
    pt = pigeons(
            target = toy_mvn_target(1000), 
            n_chains = ${config.n_chains}, 
            seed = ${config.seed},
            n_rounds = ${params.n_rounds})
    """
}
