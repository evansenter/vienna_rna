module ViennaRna
  class Rna
    include ViennaRna::RnaExtensions
    
    attr_reader :sequence, :structure
      
    def initialize(sequence, structure = nil)
      if sequence.class == self.class
        # Too bad you can't do this in a cleaner way without method chaining initialize
        @sequence  = sequence.sequence
        @structure = sequence.structure
      else
        @sequence  = sequence.upcase
        @structure = (structure == :mfe ? ViennaRna::Fold.run(seq).structure : structure)
      end
    end
      
    def safe_structure
      structure || empty_structure
    end
      
    def empty_structure
      "." * seq.length
    end
    
    alias :seq :sequence
    alias :str :safe_structure
    
    def inspect
      "#<ViennaRna::#{self.class.name} #{seq[0, 20] + ('...' if seq.length > 20)} #{str[0, 20] + ('[truncated]' if seq.length > 20)}>"
    end
  end
end