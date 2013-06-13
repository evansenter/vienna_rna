A simple gem for facilitating bindings to the ViennaRNA package (http://www.tbi.univie.ac.at/~ivo/RNA/). Note that this gem makes no effort to build and install the ViennaRNA suite locally at this time, and instead relies on its presence on the host machine. Leverages the BioRuby gem (http://bioruby.open-bio.org/) libraries for file parsing.

Simple use case:
    
    > require "vienna_rna"
    #=> true 
    > rna = ViennaRna::Fold.run(seq: "CCUCGAGGGGAACCCGAAAGGGACCCGAGAGG")
    #=> #<ViennaRna::Fold:0x007f9c48839dc0>
    > rna.structure
    #=> "((((..(((...(((....))).)))..))))" 
    > rna.mfe
    #=> -19.7

... now an even easier way ...

    > mfe_rna = RNA("CCUCGAGGGGAACCCGAAAGGGACCCGAGAGG").run(:fold).mfe_rna
    #=> echo CCUCGAGGGGAACCCGAAAGGGACCCGAGAGG | rnafold --noPS
    #=> Total runtime: 0.013 sec.
    #=> #<ViennaRna::ViennaRna::Rna CCUCGAGGGGAACCCGAAAG... ((((..(((...(((....) [truncated]>