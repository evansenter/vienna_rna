module ViennaRna
  class Rna
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
    
    def symmetric_bp_distance(other_structure)
      self.class.symmetric_bp_distance(structure, other_structure)
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
        # Takes two structures and calculates the distance between them by |symmetric difference(bp_in_a, bp_in_b)|
        raise "The two structures are not the same length" unless structure_1.length == structure_2.length
        
        bp_set_1, bp_set_2 = base_pairs(structure_1), base_pairs(structure_2)
        
        ((bp_set_1 - bp_set_2) + (bp_set_2 - bp_set_1)).count
      end
      
      def symmetric_bp_distance(structure_1, structure_2)
        # Takes two structures and calculates the distance between them by: sum { ((x_j - x_i) - (y_j - y_i)).abs }
        raise "The two structures are not the same length" unless structure_1.length == structure_2.length
  
        bp_dist = ->(array, i) { array[i] == -1 ? 0 : array[i] - i }
  
        structure_1_pairings = get_pairings(structure_1)
        structure_2_pairings = get_pairings(structure_2)
  
        structure_1.length.times.inject(0) do |distance, i|
          distance + (bp_dist[structure_1_pairings, i] - bp_dist[structure_2_pairings, i]).abs
        end
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