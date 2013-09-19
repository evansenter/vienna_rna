module ViennaRna
  module Global
    module Parser
      REGEXP = {
        mfe: / \(\s*(-?\d*\.\d*)\)$/
      }
    
      class << self
        def rnafold_mfe_structure(response)
          response.split(/\n/)[1].split(/\s+/).first
        end
      
        def rnafold_mfe(response)
          response.split(/\n/)[1].match(REGEXP[:mfe])[1].to_f
        end
      end
    end
  end
end
