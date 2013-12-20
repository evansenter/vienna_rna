module ViennaRna
  module Global
    module Parser
      REGEXP = {
        number: /-?\d*\.\d*/,
        mfe:    / \(\s*(-?\d*\.\d*)\)$/
      }
    
      class << self
        def rnafold_mfe_structure(response)
          response.split(/\n/)[1].split(/\s+/).first
        end
      
        def rnafold_mfe(response)
          response.split(/\n/)[1].match(REGEXP[:mfe])[1].to_f
        end
        
        def rnafold_ensemble_energy(response)
          response.split(/\n/)[2].split(/\s/).last.match(REGEXP[:number])[0].to_f
        end
      end
    end
  end
end
