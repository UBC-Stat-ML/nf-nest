params.nPrecompileThreads = 10

// Note: need to pass a directory to make it easy to use interactively 
julia_env = file('julia_env')
julia_env.mkdir()

// Can be used as standalone, but typically used inside a user nf file
workflow  {
    instantiate(julia_env) | precompile
}

def instantiate(julia_env) { instantiate_process(julia_env, file(julia_env/"Manifest.toml"))}

process instantiate_process {
    executor 'local' // we need internet access
    scratch false // we want changes in Manifest.toml to be saved
    input: 
        path julia_env
        path toml // needed for correct cache behaviour under updates
    output:
        path julia_env

    """
    ${activate(julia_env)}

    ENV["JULIA_PKG_PRECOMPILE_AUTO"]=0
    using Pkg
    Pkg.instantiate()
    """
}

process precompile {
    input:
        path julia_env
    output:
        path julia_env
    cpus params.nPrecompileThreads 
    memory 15.GB
    """
    ${activate(julia_env, params.nPrecompileThreads)}

    using Pkg 
    Pkg.offline(true) 
    Pkg.precompile()
    """
}

// Start Julia and with the provided environment and optionally, number of threads (1 by default) 
// Needs to be the very first line of the process script
def activate(julia_env, nThreads = 1) {
    return "#!/usr/bin/env julia --threads=${nThreads} --project=$julia_env"
}
