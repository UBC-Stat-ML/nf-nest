include { instantiate; precompile; activate } from './pkg.nf'

def combine_env = file(moduleDir/'combine_env')

def combine_csvs(results) { combine_workflow(results.collect()) }

workflow combine_workflow {
    take: 
        results 
    main:
        compiled_env = instantiate(combine_env) | precompile
        combined = combine_process(compiled_env, results)
    emit:
        combined
}

process combine_process {
    input:
        path julia_env 
        path results
    output:
        path '*.csv'
    """ 
    ${activate(julia_env)}

    using CSV 
    using CombineCSVs

    df = combine_csvs(".")
    CSV.write("combined.csv", df)
    """
}