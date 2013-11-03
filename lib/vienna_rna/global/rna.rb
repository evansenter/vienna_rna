module ViennaRna
  module Global
    class Rna
      include RnaExtensions
    
      attr_reader :sequence, :structure, :second_structure, :raw_data
      
      class << self
        def init_from_string(sequence, structure = nil, second_structure = nil)
          new(
            sequence:         sequence, 
            structure:        structure, 
            second_structure: second_structure
          )
        end
    
        def init_from_hash(hash)
          new(
            sequence:         hash[:sequence]         || hash[:seq], 
            structure:        hash[:structure]        || hash[:str_1] || hash[:str], 
            second_structure: hash[:second_structure] || hash[:str_2], 
            raw_data:         hash
          )
        end
      
        def init_from_array(array)
          init_from_string(*array)
        end
      
        def init_from_fasta(string)
          string = File.read(string).chomp if File.exist?(string)
          init_from_string(*string.split(/\n/).reject { |line| line.start_with?(">") }[0, 3])
        end
    
        def init_from_self(rna)
          # This happens when you call a ViennaRna library function with the output of something like ViennaRna::Fold.run(...).mfe
          new(
            sequence:         rna.sequence, 
            strucutre:        rna.structure, 
            second_strucutre: rna.second_structure, 
            raw_data:         rna.raw_data
          )
        end
      
        alias_method :placeholder, :new
      end
    
      def initialize(sequence: "", structure: "", second_structure: "", raw_data: {})
        @sequence, @raw_data = sequence.kind_of?(Rna) ? sequence.seq : sequence, raw_data
      
        [:structure, :second_structure].each do |structure_symbol|
          instance_variable_set(
            :"@#{structure_symbol}", 
            case structure_value = eval("#{structure_symbol}")
            when :empty then empty_structure
            when :mfe   then RNA(sequence).run(:fold).mfe_rna.structure
            when String then structure_value
            when Hash   then 
              if structure_value.keys.count > 1
                ViennaRna.debugger { "The following options hash has more than one key. This will probably produce unpredictable results: %s" % structure_value.inspect }
              end
              
              RNA(sequence).run(*structure_value.keys, *structure_value.values).mfe_rna.structure
            end
          )
        end

        if str && seq.length != str.length
          ViennaRna.debugger { "The sequence length (%d) doesn't match the structure length (%d)" % [seq, str].map(&:length) }
        end
      
        if str_2 && str_1.length != str_2.length
          ViennaRna.debugger { "The first structure length (%d) doesn't match the second structure length (%d)" % [str_1, str_2].map(&:length) }
        end
      end
    
      alias :seq   :sequence
      alias :str   :structure
      alias :str_1 :structure
      alias :str_2 :second_structure
    
      def empty_structure
        "." * seq.length
      end

      alias :empty_str :empty_structure
    
      def write_fa!(filename, comment = nil)
        filename.tap do |filename|
          File.open(filename, ?w) do |file|
            file.write("> %s\n" % comment) if comment
            file.write("%s\n" % seq)       if seq
            file.write("%s\n" % str_1)     if str_1
            file.write("%s\n" % str_2)     if str_2
          end
        end
      end
    
      def temp_fa_file!
        write_fa!(Tempfile.new("rna")).path
      end

      def run(package_name, options = {})
        ViennaRna::Package.lookup(package_name).run(self, options)
      end

      def inspect
        "#<%s>" % [
          "#{self.class.name}",
          ("#{seq[0, 20]   + (seq.length > 20   ? '...' : '')}"          if seq && !seq.empty?),
          ("#{str_1[0, 20] + (str_1.length > 20 ? ' [truncated]' : '')}" if str_1 && !str_1.empty?),
          ("#{str_2[0, 20] + (str_2.length > 20 ? ' [truncated]' : '')}" if str_2 && !str_1.empty?),
        ].compact.join(" ")
      end
    end
  end
end