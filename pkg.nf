params.nPrecompileThreads = 10
params.packagesToAdd = "" // comma separated

// Note: this will only work if passing the directory. 
julia_env = file('julia_env')

// Can use this as utility to add packages and precompile it
// example: ./nextflow run pkg.nf --packagesToAdd "CSV, DataFrames"
workflow  {
    instantiate_process(julia_env, params.packagesToAdd) | precompile
}

def instantiate(julia_env) { instantiate_process(julia_env, "")}

process instantiate_process {
    executor 'local' // we need internet access
    scratch false // we want changes in Manifest.toml to be saved
    input: 
        path julia_env
        val packages

    output:
        path julia_env

    """
    ${activate(julia_env)}

    ENV["JULIA_PKG_PRECOMPILE_AUTO"]=0
    using Pkg
    Pkg.instantiate()
    ${packageAddStr(packages)}
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

def activate(julia_env, nThreads = 1) {
    return "#!/usr/bin/env julia --threads=${nThreads} --project=$julia_env"
}

def packageAddStr(input) {
    def str = input.replaceAll(" ", "")
    if (str == "") 
        "" // Pkg.add([]) and Pkg.add(String[]) crashes/stalls
    else {
        def p = str.split(",")
        "Pkg.add(${quotes(p)})"
    }
}
def quote(str) { "\"$str\""}
def quotes(list) { "[" + list.collect{quote(it)}.join(", ") + "]"}
