module ViennaRna
  module Parser
    class << self
      def mfe(response)
        response.split(/\n/).last.match(/ \(\s*(-?\d*\.\d*)\)$/)[1].to_f
      end
    end
  end
end
