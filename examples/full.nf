// includes are relative to the .nf file, should always start with ./ or ../
include { crossProduct; filed } from '../cross.nf'
include { instantiate; precompile; activate } from '../pkg.nf'
include { combine_csvs; } from '../combine.nf'

def julia_env = file(projectDir/'julia_env')

def variables = [
    seed: 1..2,
    n_chains: 2..3, 
]

workflow {
    compiled_env = instantiate(julia_env) | precompile
    configs = crossProduct(variables)
    run_julia(compiled_env, configs) | combine_csvs
}

process run_julia {
    input:
        path julia_env 
        val config 
    output:
        path "${filed(config)}"
    """
    ${activate(julia_env)}

    # run your code
    using Pigeons 
    using CSV 
    pt = pigeons(
            target = toy_mvn_target(1000), 
            n_chains = ${config.n_chains}, 
            seed = ${config.seed})

    # organize output as follows:
    #   - create a directory with name controlled by filed(config)
    #     to keep track of input configuration
    #   - put any number of CSV in there
    mkdir("${filed(config)}")
    CSV.write("${filed(config)}/summary.csv", pt.shared.reports.summary)
    CSV.write("${filed(config)}/swap_prs.csv", pt.shared.reports.swap_prs)
    """
}