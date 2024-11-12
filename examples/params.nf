include { crossProduct; filed; deliverables } from '../cross.nf'
include { instantiate; precompile; activate } from '../pkg.nf'
include { combine_csvs; } from '../combine.nf'

def julia_env = file(moduleDir/'julia_env')
def plot_script = file(moduleDir/'plot.jl')

params.n_rounds = 5

def variables = [
    seed: 1..10,
    n_chains: [10, 20], 
]

workflow {
    compiled_env = instantiate(julia_env) | precompile
    configs = crossProduct(variables)
    combined = run_julia(compiled_env, configs) | combine_csvs
    plot(compiled_env, plot_script, combined)
}

process run_julia {
    input:
        path julia_env 
        val config 
    output:
        path "${filed(config)}"
    """
    ${activate(julia_env)}

    # run your code
    using Pigeons 
    using CSV 
    pt = pigeons(
            target = toy_mvn_target(1000), 
            n_chains = ${config.n_chains}, 
            seed = ${config.seed},
            n_rounds = ${params.n_rounds})

    mkdir("${filed(config)}")
    CSV.write("${filed(config)}/summary.csv", pt.shared.reports.summary)
    CSV.write("${filed(config)}/swap_prs.csv", pt.shared.reports.swap_prs)
    """
}

process plot {
    input:
        path julia_env 
        path plot_script
        path combined_csvs_folder 
    output:
        path '*.png'
        path combined_csvs_folder
    publishDir "${deliverables(workflow, params)}", mode: 'copy', overwrite: true
    """
    ${activate(julia_env)}

    include("$plot_script")
    create_plots("$combined_csvs_folder")
    """
}