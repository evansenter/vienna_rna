module ViennaRna
  class Rna
    include ViennaRna::RnaExtensions
    
    attr_reader :sequence, :structure, :raw_data
      
    class << self
      def init_from_string(sequence, structure = nil)
        new(sequence, structure)
      end
    
      def init_from_hash(hash)
        new(data[:sequence] || data[:seq], data[:structure] || data[:str], data)
      end
      
      def init_from_array(array)
        new(*array)
      end
      
      def init_from_fasta(string)
        init_from_string(*string.split(/\n/).reject { |line| line.start_with?(">") })
      end
    
      def init_from_self(rna)
        # This happens when you call a ViennaRna library function with the output of something like ViennaRna::Fold.run(...).mfe
        new(rna.sequence, rna.structure, rna.raw_data)
      end
    end
    
    def initialize(sequence, structure, raw_data = {})
      @sequence, @raw_data = sequence, raw_data
      
      @structure = case structure
      when :empty then empty_structure
      when :mfe   then ViennaRna::Fold.run(seq).structure
      when String then structure
      end
    end
    
    alias :seq :sequence
    alias :str :structure
    
    def inspect
      if structure.present?
        "#<ViennaRna::#{self.class.name} #{seq[0, 20] + ('...' if seq.length > 20)} #{str[0, 20] + (' [truncated]' if str.length > 20)}>"
      else
        "#<ViennaRna::#{self.class.name} #{seq[0, 20] + ('...' if seq.length > 20)}>"
      end
    end
    
    private
      
    def empty_structure
      "." * seq.length
    end
  end
end