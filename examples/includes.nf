include { activate; } from "../pkg.nf"

def julia_files = file(moduleDir/"julia/*.jl")

workflow {
    run_julia(julia_files)
}

process run_julia {
    debug true
    input:
        file julia_files
    """
    ${activate()}
    include("a.jl")
    include("b.jl")
    """
}