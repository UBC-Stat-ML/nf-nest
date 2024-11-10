using DataFrames 
using AlgebraOfGraphics 
using CairoMakie 
using CSV

function create_plots(combined_csvs_folder)
    df = CSV.read("$combined_csvs_folder/summary.csv", DataFrame)
    plot = data(df) * mapping(:round, :global_barrier, color = :n_chains)
    fg = draw(plot)
    save("plot.png", fg)
end

