module ViennaRna
  module Parser
    REGEXP = {
      mfe: / \(\s*(-?\d*\.\d*)\)$/
    }
    
    class << self
      def mfe(response)
        response.split(/\n/).last.match(REGEXP[:mfe])[1].to_f
      end
    end
  end
end
