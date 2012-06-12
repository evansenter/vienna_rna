module ViennaRna
  class Fold < Base
    attr_reader :structure, :mfe
    
    def post_process
      structure = @response.split(/\n/).last.gsub(/ \(\s*(-?\d*\.\d*)\)$/, "")
      
      unless fasta.seq.length == structure.length
        raise "Sequence: '#{fasta.seq}'\nStructure: '#{structure}'"
      else
        @structure, @mfe = structure, $1.to_f
      end
    end
    
    module Batch
      def with_different_structures
        run.inject(Hash.new { |hash, key| hash[key] = [] }) do |hash, folded_sequence|
          hash.tap do
            hash[folded_sequence.structure] << folded_sequence
          end
        end.values.map(&:first)
      end
    end
  end
end