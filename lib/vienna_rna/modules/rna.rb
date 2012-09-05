module ViennaRna
  class Rna
    attr_reader :sequence, :structure
      
    def initialize(sequence, structure = nil)
      @sequence  = sequence.upcase
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
    
    def bp_distance(other_structure)
      self.class.bp_distance(structure, other_structure)
    end
    
    def base_pairs
      self.class.base_pairs(structure)
    end
            
    def get_pairings
      self.class.get_pairings(structure)
    end
    
    def dishuffle
      self.class.shuffle(sequence, 2)
    end
    
    def inspect
      "#<ViennaRna::#{self.class.name} #{seq[0, 20] + ('...' if seq.length > 20)} #{str[0, 20] + ('[truncated]' if seq.length > 20)}>"
    end
    
    class << self
      def generate_sequence(sequence_length)
        # 0th order Markov chain w/ uniform probability distribution
        sequence_length.times.inject("") { |string, _| string + %w[A U C G][rand(4)] }
      end
      
      def shuffle(sequence, token_length = 2)
        Shuffle.new(sequence).shuffle(token_length)
      end
      
      def bp_distance(structure_1, structure_2)
        raise "The two structures are not the same length" unless structure_1.length == structure_2.length
        
        bp_set_1, bp_set_2 = base_pairs(structure_1), base_pairs(structure_2)
        
        ((bp_set_1 - bp_set_2) + (bp_set_2 - bp_set_1)).count
      end
      
      def base_pairs(structure)
        get_pairings(structure).each_with_index.inject(Set.new) do |set, (j, i)|
          j >= 0 ? set << Set[i, j] : set
        end
      end
    
      def get_pairings(structure)
      	stack = []
      
        structure.each_char.each_with_index.inject(Array.new(structure.length, -1)) do |array, (symbol, index)|
      	  array.tap do      
      	    case symbol
      	    when "(" then stack.push(index)
      	    when ")" then 
      	      if stack.empty?
      	        raise "Too many ')' in '#{structure}'"
      	      else
      	        stack.pop.tap do |opening|
      	          array[opening] = index
      	          array[index]   = opening
      	        end
      	      end
      	    end
      	  end
      	end.tap do
      	  raise "Too many '(' in '#{structure}'" unless stack.empty?
      	end
      end
    end
  end
end