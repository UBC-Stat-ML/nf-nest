workflow  {
    test()
}

process test {
    debug true 
    """
    echo Test successful
    """
}