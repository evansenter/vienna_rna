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
    
    def dishuffle
      self.class.shuffle(sequence, 2)
    end
    
    class << self
      def generate_sequence(sequence_length)
        # 0th order Markov chain w/ uniform probability distribution
        sequence_length.times.inject("") { |string, _| string + %w[A U C G][rand(4)] }
      end
      
      def shuffle(sequence, token_length = 2)
        Shuffle.new(sequence).shuffle(token_length)
      end
    end
  end
end