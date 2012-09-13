module ViennaRna
  class Fold < Base
    BASE_FLAGS = {
      "-noPS" => :empty
    }
    
    attr_reader :mfe_rna, :structure, :mfe
    
    def post_process
      structure = @response.split(/\n/).last.gsub(Parser::REGEXP[:mfe], "")
      
      unless data.seq.length == structure.length
        raise "Sequence: '#{data.seq}'\nStructure: '#{structure}'"
      else
        @mfe_rna, @structure, @mfe = ViennaRna::Rna.new(data.seq, structure), structure, Parser.mfe(@response)
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