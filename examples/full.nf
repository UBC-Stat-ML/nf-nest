// includes are relative to the .nf file, should always start with ./ or ../
include { crossProduct; auto_name } from '../cross.nf'
include { instantiate; precompile; activate } from '../pkg.nf'
include { combine_csvs; } from '../combine.nf'


def julia_env = file(projectDir/'julia_env')

def variables = [
    seed: 1..3,
    n_chains: 1..3, 
]

workflow {
    compiled_env = instantiate(julia_env) | precompile
    configs = crossProduct(variables)
    run_julia(compiled_env, configs) | combine_csvs
}

process run_julia {
    time 1.min
    cpus 1 
    memory 1.GB
    input:
        path julia_env 
        val config 
    output:
        path "*.csv"
    """
    ${activate(julia_env)}

    using Pigeons 
    using CSV 

    pt = pigeons(target = toy_mvn_target(1000))
    CSV.write("${auto_name(config)}", pt.shared.reports.summary)
    """
}