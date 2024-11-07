workflow  {
    hello()
}

process hello {
    debug true 
    """
    echo Hello world!
    """
}