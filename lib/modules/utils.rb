require "matrix"
require "gnuplot"

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
      
      def plot(data, options = {})
        Gnuplot.open do |gnuplot|
          Gnuplot::Plot.new(gnuplot) do |plot|
            case options[:output]
            when /file/i then
              plot.output(options[:filename])
              plot.terminal("png size 800,600")
            end
            
            plot.title(options[:title])
            plot.xlabel(options[:x_label])
            plot.ylabel(options[:y_label])

            plot.data = data.map do |data_hash|
              Gnuplot::DataSet.new([data_hash[:x], data_hash[:y]]) do |dataset|
                dataset.with = data_hash[:style] || "points"
                data_hash[:title] ? dataset.title = data_hash[:title] : dataset.notitle
              end
            end
          end
        end
      end
    end
  end
end