module ViennaRna
  class Eval < Base
    attr_reader :mfe
    
    def post_process
      @mfe = Parser.rnafold_mfe(@response)
    end
  end
end
