module ViennaRna
  module Package
    class Fold < Base
      self.default_flags = {
        "-noPS" => :empty
      }
    
      attr_reader :mfe_rna, :structure, :mfe, :ensemble_energy
    
      def post_process
        structure = ViennaRna::Global::Parser.rnafold_mfe_structure(response)
      
        unless data.seq.length == structure.length
          raise "Sequence: '#{data.seq}'\nStructure: '#{structure}'"
        else
          @mfe_rna, @structure, @mfe = RNA.from_string(data.seq, structure), structure, ViennaRna::Global::Parser.rnafold_mfe(response)
        end
        
        if flags[:p] == 0
          @ensemble_energy = ViennaRna::Global::Parser.rnafold_ensemble_energy(response)
        end
      end
    end
  end
end