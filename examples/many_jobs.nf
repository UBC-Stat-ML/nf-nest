// includes are relative to the .nf file, should always start with ./ or ../
include { crossProduct } from '../cross.nf'
include { instantiate; precompile; activate } from '../pkg.nf'

def julia_env = file('julia_env')

def variables = [
    first: 1..3,
    second: 1..3,
    operation: ["+", "*"]
]

workflow {
    // prepare Julia env
    compiled_env = instantiate(julia_env) | precompile
    // look at all combinations of variables
    configs = crossProduct(variables)
    // run Julia on 18 nodes!
    run_julia(compiled_env, configs)
}

process run_julia {
    debug true
    input:
        path julia_env 
        val config 
    """
    ${activate(julia_env)}

    @show ${config.first} ${config.operation} ${config.second}
    """
}