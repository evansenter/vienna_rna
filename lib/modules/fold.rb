module ViennaRna
  class Fold < Base
    attr_reader :structure, :mfe
    
    def post_process(response)
      tap do
        structure = response.split(/\n/).last.gsub(/ \(\s*(-?\d*\.\d*)\)$/, "")
      
        unless fasta.seq.length == structure.length
          raise "Sequence: '#{fasta.seq}'\nStructure: '#{structure}'"
        else
          @structure, @mfe = structure, $1
        end
      end
    end
  end
  
  # Mix this baby into the Batch class after I write it for great cleanness!
  module Batch
    def prune_same_structures
      
    end
  end
end