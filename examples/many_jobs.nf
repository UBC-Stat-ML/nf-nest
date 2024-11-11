// includes are relative to the .nf file, should always start with ./ or ../
include { crossProduct; filed; deliverables } from '../cross.nf'
include { instantiate; precompile; activate } from '../pkg.nf'

def variables = [
    first: 1..3,
    second: 1..3,
    operation: ["+", "*"]
]

workflow {
    // look at all combinations of variables
    configs = crossProduct(variables)
    // run Julia on 18 nodes!
    run_julia(configs)
}

process run_julia {
    debug true // by default, standard out is not shown, use this to show it
    time 1.min
    cpus 1 
    memory 1.GB
    input:
        val config 
    """
    ${activate()}

    @show ${config.first} ${config.operation} ${config.second}
    """
}