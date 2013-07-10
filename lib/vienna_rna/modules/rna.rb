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
      when :mfe   then ViennaRna::Fold.run(Rna.init_from_string(seq)).structure
      when String then structure
      end
    end
    
    alias :seq :sequence
    alias :str :structure
    
    
    def inspect
      case [!(seq || "").empty?, !(str || "").empty?]
      when [true, true] then
        "#<#{self.class.name} #{seq[0, 20] + (seq.length > 20 ? '...' : '')} #{str[0, 20] + (str.length > 20 ? ' [truncated]' : '')}>"
      when [true, false] then
        "#<#{self.class.name} #{seq[0, 20] + (seq.length > 20 ? '...' : '')}>"
      when [false, false] then
        "#<#{self.class.name}>"
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

    def run(module_name, options = {})
      if rna_module = ViennaRna.const_missing("#{module_name}".camelize)
        rna_module.run(self, options)
      else
        raise ArgumentError.new("#{module_name} can't be resolved as an executable")
      end
    end
    
    private
      
    def empty_structure
      "." * seq.length
    end
  end
end