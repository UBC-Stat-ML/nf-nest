include { crossProduct } from '../cross.nf'
include { instantiate; precompile; activate } from '../pkg.nf'

def julia_env = file('julia_env')

def variables = [
    index: 1..10,
]

workflow {
    configs = crossProduct(variables)
    compiled_env = instantiate(julia_env) | precompile 
    test(compiled_env, configs)
}

process test {
    input:
        path julia_env 
        val config 

    debug true

    """
    ${activate(julia_env)}

    using LinearAlgebra

    @show "${config}"
    """

}