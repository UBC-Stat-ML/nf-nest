include { instantiate; activate; } from './pkg.nf'

params.julia_env = 'julia_env'
julia_env = file(params.julia_env)
julia_env.mkdir()

params.cuda_version = "12.5"

// Can be used as standalone, but typically used inside a user nf file
workflow  {
    instantiate(julia_env) | precompile_gpu
}

process precompile_gpu {
    executor 'local' // we need internet access for GPU driver download
    input:
        path julia_env
    output:
        path julia_env
    memory 15.GB
    """
    ${activate(julia_env)}

    ENV["JULIA_PKG_PRECOMPILE_AUTO"]=0
    
    using CUDA 
    CUDA.set_runtime_version!(v"${params.cuda_version}")

    using Pkg 
    Pkg.precompile()
    """
}
