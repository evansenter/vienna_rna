A simple gem for facilitating bindings to the ViennaRNA package (http://www.tbi.univie.ac.at/~ivo/RNA/). Note that this gem makes no effort to build and install the ViennaRNA suite locally at this time, and instead relies on its presence on the host machine. Leverages the BioRuby gem (http://bioruby.open-bio.org/) libraries for file parsing.

Simple use case:
ruby-1.9.3-p125 :001 > require "vienna_rna"
 => true 
ruby-1.9.3-p125 :002 > rna = ViennaRna::Fold.run(seq: "CCUCGAGGGGAACCCGAAAGGGACCCGAGAGG")
 => #<ViennaRna::Fold:0x007f9c48839dc0>
ruby-1.9.3-p125 :003 > rna.structure
 => "((((..(((...(((....))).)))..))))" 
ruby-1.9.3-p125 :004 > rna.mfe
 => -19.7
