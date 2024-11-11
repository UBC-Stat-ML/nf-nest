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
    configs = crossProduct(variables)
    // run Julia on 18 nodes!
    run_julia(configs)

    // equivalent syntax:
    // crossProduct(variables) | run_julia
}

process run_julia {
    debug true // by default, standard out is not shown, use this to show it
    
    // information used when submitting job to queue
    time 2.min
    cpus 1 
    memory 5.GB

    input:
        val config 
    """
    ${activate()}
    # ^ this is just a shortcut for:
    #!/usr/bin/env julia --threads=1

    @show ${config.first} ${config.operation} ${config.second}
    """
}