module ViennaRna
  module Utils
    class << self
      def fastas_from_file(path)
        # Force it to not be lazy.
        Bio::FlatFile.auto(path).to_enum.map { |fasta| fasta }
      end
      
      def write_fastas!(fastas, directory, base_name, group_size = 10)
        fastas.each_slice(group_size).each_with_index do |fasta_group, i|
          path = File.join(directory, base_name + "_#{i}.fa")
          
          unless File.exists?(path)
            File.open(path, "w") do |file|
              fasta_group.each do |folding|
                file.write(">%s\n%s\n" % [folding.fasta.definition, folding.fasta.seq])
              end
            end
          else
            puts "Warning: file '#{path}' exists. Skipping."
          end
        end
      end

      def regress(x, y, degree)
        x_data   = x.map { |i| (0..degree).map { |power| i ** power.to_f } }
        x_matrix = Matrix[*x_data]
        y_matrix = Matrix.column_vector(y)

        ((x_matrix.transpose * x_matrix).inverse * x_matrix.transpose * y_matrix).transpose.to_a[0]
      end
    end
  end
end