process compile_stan {
    label 'containerized' 

    input:
        path stan_file
    output:
        path "${stan_file.baseName}"
        
    """
    echo $stan_file

    # name of stan file without extension
    base_name=`basename $stan_file .stan`

    # need to run Stan's make file from the CMDSTAN dir
    CUR=`pwd`
    cd \$CMDSTAN
    make \$CUR/\$base_name
    """
}

process run_stan {
    label 'containerized' 

    input:
        path stan_exec 
        path data

    """
    ./$stan_exec sample \
        data file=$data \
        output file=samples.csv 

    # Compute ESS from Stan's stansummary utility
    \$CMDSTAN/bin/stansummary samples.csv --csv_filename ess.csv
    """
}