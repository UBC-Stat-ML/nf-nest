#!/usr/bin/env julia 

ENV["JULIA_PKG_PRECOMPILE_AUTO"]=0
using Pkg 
Pkg.activate("combine_env") 
Pkg.add(url = "https://github.com/UBC-Stat-ML/CombineCSVs")