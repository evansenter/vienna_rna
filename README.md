ViennaRna
------------------------

[![Gem Version](https://badge.fury.io/rb/vienna_rna.png)](http://badge.fury.io/rb/vienna_rna)

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

... and now you can even do crazy stuff like this (taking a sequence, inferring the MFE, calculating the 2D energy landscape and computing the MFPT by chaining commands)!

    RNA("GGGGGCCCCC", :empty, fold: { d: 0 }).run(:fftbor2d).chain(:mfpt).mfpt
    #=> ViennaRna::Package::Fold: {"-noPS"=>:empty, :d=>0}
    #=> echo 'GGGGGCCCCC' | RNAfold --noPS -d 0
    #=> Total runtime: 0.014 sec.
    #=> ViennaRna::Package::Fftbor2d: {:S=>:empty}
    #=> Running FFTbor2D on #<ViennaRna::Global::Rna GGGGGCCCCC .......... (((....)))>
    #=> FFTbor2D -S /var/folders/_2/0js_xvm95zz8jv0lxlh8p__40000gn/T/rna20131103-7845-1ok9xnt
    #=> Total runtime: 0.041 sec.
    #=> ViennaRna::Package::Mfpt: {:X=>:empty, :H=>:empty, :N=>10, :Q=>"1e-8"}
    #=> RNAmfpt -X -H -N 10 -Q 1e-8 /var/folders/_2/0js_xvm95zz8jv0lxlh8p__40000gn/T/rna20131103-7845-1h1uz0l
    #=> Total runtime: 0.012 sec.
    #=> 2160.58769316