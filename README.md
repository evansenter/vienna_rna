ViennaRna
------------------------

A simple gem for facilitating bindings to the ViennaRNA package (http://www.tbi.univie.ac.at/~ivo/RNA/), amongst other RNA packages. Note that this gem makes no effort to build and install the ViennaRNA suite locally at this time, and instead relies on its presence on the host machine. Also includes a lot of utilities surrounding RNA sequence / structure parsing, graphing using R (via RinRuby) and other analysis tools. Used privately as the foundation for much of the research I do at http://bioinformatics.bc.edu/clotelab/

Simple use case:
    
    > require "vienna_rna"
    #=> true 
    > rna = ViennaRna::Package::Fold.run(seq: "CCUCGAGGGGAACCCGAAAGGGACCCGAGAGG")
    #=> #<ViennaRna::Fold:0x007f9c48839dc0>
    > rna.structure
    #=> "((((..(((...(((....))).)))..))))" 
    > rna.mfe
    #=> -19.7

... now an even easier way ...

    > mfe_rna = RNA("CCUCGAGGGGAACCCGAAAGGGACCCGAGAGG").run(:fold).mfe_rna
    #=> echo CCUCGAGGGGAACCCGAAAGGGACCCGAGAGG | rnafold --noPS
    #=> Total runtime: 0.013 sec.
    #=> #<ViennaRna::Rna CCUCGAGGGGAACCCGAAAG... ((((..(((...(((....) [truncated]>
