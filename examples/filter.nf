// we use utilities in the nf-nest submodule
// in user scripts, path would be './nf-nest/cross.nf' 
include { crossProduct; filed; deliverables } from '../cross.nf'
include { instantiate; precompile; activate } from '../pkg.nf'

def variables = [
    first: 1..3,
    second: 1..3,
    operation: ["+", "*"]
]

// specifies the order of operations
workflow {
    // look at all combinations of variables
    configs = crossProduct(variables).filter{ config -> config.first == config.second }
    // run Julia on 18 nodes!
    run_julia(configs)
}

process run_julia {
    debug true // by default, standard out is not shown, use this to show it
    input:
        val config 
    """
    ${activate()}

    @show ${config.first} ${config.operation} ${config.second}
    """
}