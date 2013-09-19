module ViennaRna
  module Package
    class Eval < Base
      attr_reader :mfe
    
      def post_process
        @mfe = ViennaRna::Global::Parser.rnafold_mfe(@response)
      end
    end
  end
end
