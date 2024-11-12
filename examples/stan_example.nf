include { compile_stan; run_stan; } from "./stan.nf"

def stanModel = file("https://raw.githubusercontent.com/Julia-Tempering/Pigeons.jl/refs/heads/main/examples/stan/bernoulli.stan")
def data = file("https://raw.githubusercontent.com/Julia-Tempering/Pigeons.jl/refs/heads/main/examples/stan/bernoulli.data.json")

workflow {
    compiled = compile_stan(stanModel)
    run_stan(compiled, data)
}