module ViennaRna
  class Rna
    attr_reader :sequence, :structure
      
    def initialize(sequence, structure = nil)
      @sequence  = sequence
      @structure = (structure == :mfe ? ViennaRna::Fold.run(seq).structure : structure)
    end

    alias :seq :sequence
    alias :str :structure
      
    def safe_structure
      structure || empty_structure
    end
      
    def empty_structure
      "." * seq.length
    end
  end
end