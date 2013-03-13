module ViennaRna
  class Rna
    include ViennaRna::RnaExtensions
    
    attr_reader :sequence, :structure, :raw_data
      
    class << self
      def init_from_string(sequence, structure = nil)
        new(sequence, structure)
      end
    
      def init_from_hash(hash)
        new(hash[:sequence] || hash[:seq], hash[:structure] || hash[:str], hash)
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
      case [sequence.present?, structure.present?]
      when [true, true] then
        "#<ViennaRna::#{self.class.name} #{seq[0, 20] + (seq.length > 20 ? '...' : '')} #{str[0, 20] + (str.length > 20 ? ' [truncated]' : '')}>"
      when [true, false] then
        "#<ViennaRna::#{self.class.name} #{seq[0, 20] + (seq.length > 20 ? '...' : '')}>"
      when [false, false] then
        "#<ViennaRna::#{self.class.name}>"
      end
    end
    
    def write_fa!(filename, comment = "")
      (File.basename(filename, ".fa") + ".fa").tap do |filename|
        File.open(filename, "w") do |file|
          file.write("> %s\n" % comment) if comment
          file.write("%s\n" % seq)       if seq
          file.write("%s\n" % str)       if str
        end
      end
    end
    
    private
      
    def empty_structure
      "." * seq.length
    end
  end
end