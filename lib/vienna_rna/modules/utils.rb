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
            plot.autoscale
            
            case options[:output]
            when /file/i then
              plot.output(options[:filename])
              plot.terminal("png size %s" % (options[:dimensions] || "800,600"))
            end
            
            (options[:plot] || {}).keys.each do |option|
              plot.send(option, options[:plot][option])
            end

            plot.data = data.map do |data_hash|
              Gnuplot::DataSet.new([data_hash[:x], data_hash[:y]]) do |dataset|
                dataset.with      = data_hash[:style] || "points"
                dataset.linecolor = "rgb '#{data_hash[:color]}'" if data_hash[:color]

                data_hash[:title] ? dataset.title = data_hash[:title] : dataset.notitle
              end
            end
          end
        end
      end
      
      def splot(data, options = {})
        # [[x_1, y_1, z_1], [x_2, y_2, z_2], ...]
        orthogonal_data = data.inject([[], [], []]) { |array, list| array.zip(list).map { |a, e| a << e } }
        
        Gnuplot.open do |gnuplot|
          Gnuplot::SPlot.new(gnuplot) do |plot|
            plot.autoscale
            
            case options[:output]
            when /file/i then
              plot.output(options[:filename])
              plot.terminal("png size 800,600")
            end
            
            (options[:plot] || {}).keys.each do |option|
              plot.send(option, options[:plot][option])
            end

            plot.data = [
              Gnuplot::DataSet.new(orthogonal_data) do |dataset|
                dataset.with = options[:style] || "lines"
              end
            ]
          end
        end
      end
      
      def histogram(data, title = "", options = {})
        bin_size = options.delete(:bin_size) || 1
        half     = bin_size / 2.0
        range    = Range.new((data.min - half).floor, (data.max + half).ceil)
        groups   = (range.min + half).step(range.max, bin_size).map { |x| [x, data.count { |i| i >= x - half && i < x + half }] }
        
        options.merge!(output: "file") if options[:filename]
        options.merge!({
          plot: {
            title:  title,
            yrange: "[0:#{groups.map(&:last).max * 1.1}]",
            xtics:  "#{[bin_size, 5].max}",
            style:  "fill solid 0.5 border"
          }
        })
  
        plot([{ x: groups.map(&:first), y: groups.map(&:last), style: "boxes" }], options)
      end
      
      def roc(data, title = "", options = {})
        # data = [[true_score_1, true_score_2, ...], [false_score_1, false_score_2, ...]]
        # This 'twiddle' removes duplicates by adding a very small random number to any repeated value
        data = data.map { |scores| scores.group_by(&:_ident).values.inject([]) { |array, values| array + (values.size > 1 ? values.map { |i| i + 1e-8 * (rand - 0.5) } : values) } }
        
        roc_curve = ROC.curve_points({ 1 => data[0], -1 => data[1] }.inject([]) { |data, (truth, values)| data.concat(values.map { |i| [i, truth] })})
        area      = roc_curve.each_cons(2).inject(0) do |sum, (a, b)| 
          delta_x, delta_y = b[0] - a[0], b[1] - a[1]
          sum + (delta_x * delta_y / 2 + delta_x * [a[1], b[1]].min)
        end
        
        options.merge!(output: "file") if options[:filename]
        options.merge!({ plot: { title: "%s %s %.4f" % [title, "AUC:", area] } })
  
        plot([{ x: roc_curve.map(&:first), y: roc_curve.map(&:last), style: "lines" }], options)
      end
      
      def quick_plot(data, title = "", options = {})
        quick_overlay([{ data: data }], title, options)
      end
      
      def quick_overlay(data, title = "", options = {})
        # [{ data: [[x_0, y_0], [x_1, y_1], ...], label: "Label" }, { data: [[x_0, y_0], [x_1, y_1], ...] }]
        options[:plot] = ((options[:plot] || {}).merge(title: title))
        options.merge!(output: "file") if options[:filename]
        
        plot(data.map { |hash| { title: hash[:label], x: hash[:data].map(&:first), y: hash[:data].map(&:last), style: "linespoints" } }, options)
      end
    end
  end
end