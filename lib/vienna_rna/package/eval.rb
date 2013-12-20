module ViennaRna
  module Package
    class Eval < Base
      self.call_with = [:seq, :str]
      
      attr_reader :mfe
    
      def post_process
        @mfe = ViennaRna::Global::Parser.rnafold_mfe(response)
      end
    end
  end
end
