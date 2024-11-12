include { instantiate; precompile_gpu; } from "../pkg_gpu.nf"
include { activate; } from "../pkg.nf"

def julia_env = file('julia_env')

workflow {
    instantiate(julia_env) | precompile_gpu | run_julia
}

process run_julia {
    debug true
    label 'gpu'
    input:
        path julia_env
    """
    ${activate(julia_env)}

    using CUDA 

    println("CPU")
    x = rand(5000, 5000);
    @time x * x;
    @time x * x;

    println("GPU")
    x = CUDA.rand(5000, 5000);
    @time x * x;
    @time x * x;

    CUDA.versioninfo()
    """
}