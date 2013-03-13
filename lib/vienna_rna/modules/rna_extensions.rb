module ViennaRna
  module RnaExtensions
    def self.included(base)
      base.extend(ClassMethods)
      base.extend(StructureBasedClassAndInstanceMethods)
      
      base.class_eval do
        StructureBasedClassAndInstanceMethods.public_instance_methods.each do |class_method|
          define_method(class_method) do |*args|
            self.class.send(class_method, *[structure].concat(args))
          end
        end
      end
      
      base.send(:include, InstanceMethods)
    end
    
    module ClassMethods
      def generate_sequence(sequence_length)
        # 0th order Markov chain w/ uniform probability distribution
        Rna.init_from_string(sequence_length.times.inject("") { |string, _| string + %w[A U C G][rand(4)] })
      end
      
      def shuffle(sequence, token_length = 2)
        Shuffle.new(sequence).shuffle(token_length)
      end
    end
    
    module StructureBasedClassAndInstanceMethods
      # All the methods in here are also copied in as instance methods, where the first argument is the ViennaRna::Rna#structure
      
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
      
      def max_bp_distance(structure)
        base_pairs(structure).count + ((structure.length - 3) / 2.0).floor
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
    
    module InstanceMethods
      def dishuffle
        self.class.shuffle(sequence, 2)
      end
    end
  end
end