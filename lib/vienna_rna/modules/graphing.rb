module ViennaRna
  module Graphing
    module R
      class << self
        def graph(&block)
          begin
            (yield (r_instance = RinRuby.new)).tap { r_instance.close }
          rescue RuntimeError => e
            raise unless e.message == "Unsupported data type on R's end"
          end
        end

        def line_graph(data, title: nil, type: "l", x_label: "Independent", y_label: "Dependent", filename: false)
          graph do |r|
            r.assign("line_graph.x", data.map(&:first))
            r.assign("line_graph.y", data.map(&:last))

            if filename && (filename = filename.end_with?(".pdf") ? filename : filename + ".pdf")
              r.eval <<-STR
                pdf("#{filename}", 6, 6)
                plot(line_graph.x, line_graph.y, xlab = "#{x_label}", ylab = "#{y_label}", main = "#{title || 'Line Graph'}", type = "#{type}")
                dev.off()
              STR
            else
              r.eval <<-STR
                quartz("Histogram", 6, 6)
                plot(line_graph.x, line_graph.y, xlab = "#{x_label}", ylab = "#{y_label}", main = "#{title || 'Line Graph'}", type = "#{type}")
              STR
            end
          end
        end
        
        def histogram(data, title: nil, x_label: "Bins", bin_size: 1, relative: false, filename: false)
          half     = bin_size / 2.0
          range    = Range.new((data.min - half).floor, (data.max + half).ceil)
          breaks   = (range.min + half).step(range.max + half, bin_size).to_a
          
          graph do |r|
            r.assign("histogram.data", data)
            r.assign("histogram.breaks", breaks)

            if filename && (filename = filename.end_with?(".pdf") ? filename : filename + ".pdf")
              r.eval <<-STR
                pdf("#{filename}", 6, 6)
                hist(histogram.data, breaks = histogram.breaks, xlab = "#{x_label} (width: #{bin_size})", main = "#{title || 'Histogram'}", freq = #{relative ? 'FALSE' : 'TRUE'})
                dev.off()
              STR
            else
              r.eval <<-STR
                quartz("Histogram", 6, 6)
                hist(histogram.data, breaks = histogram.breaks, xlab = "#{x_label} (width: #{bin_size})", main = "#{title || 'Histogram'}", freq = #{relative ? 'FALSE' : 'TRUE'})
              STR
            end
          end
        end
        
        def matrix_heatmap(x, y, z, title: nil, x_label: "Column index", y_label: "Row index", filename: false, num_colors: 64)
          graph do |r|
            if r.pull("ifelse('Matrix' %in% rownames(installed.packages()), 1, -1)") > 0
              r.assign("matrix.i", x)
              r.assign("matrix.j", y)
              r.assign("matrix.x", z)
              r.eval <<-STR
                require("Matrix")
                matrix.data <- sparseMatrix(
                i      = matrix.i,
                j      = matrix.j,
                x      = matrix.x,
                index1 = F
                )
              STR

              if filename && (filename = filename.end_with?(".pdf") ? filename : filename + ".pdf")
                # r.eval <<-STR
                #   pdf("#{filename}", 6, 6)
                #   plot(line_graph.x, line_graph.y, xlab = "#{x_label}", ylab = "#{y_label}", main = "#{title || 'Line Graph'}", type = "#{type}")
                #   dev.off()
                # STR
              else
                r.eval <<-STR
                  quartz("Heatmap", 6, 6)
                  image(
                    x    = 1:dim(matrix.data)[[1]], 
                    y    = 1:dim(matrix.data)[[2]], 
                    z    = as.matrix(matrix.data),
                    col  = heat.colors(#{num_colors}),
                    zlim = c(min(matrix.x), max(matrix.x)),
                    xlab = "#{x_label}",
                    ylab = "#{y_label}"
                  )
                  title("#{title || 'Matrix Heatmap'}")
                STR
              end
            else
              puts "Please install the Matrix package for R before using this function."
            end
          end
        end
        
        def roc(data, title = "", options = {})
          # data = [[true_score_1, true_score_2, ...], [false_score_1, false_score_2, ...]]

          if R.pull("ifelse('ROCR' %in% rownames(installed.packages()), 1, -1)") > 0

          else
            puts "Please install the ROCR package for R before using this function."
          end

          # roc_curve = ROC.curve_points({ 1 => data[0], -1 => data[1] }.inject([]) { |data, (truth, values)| data.concat(values.map { |i| [i, truth] })})
          # area      = roc_curve.each_cons(2).inject(0) do |sum, (a, b)| 
          #   delta_x, delta_y = b[0] - a[0], b[1] - a[1]
          #   sum + (delta_x * delta_y / 2 + delta_x * [a[1], b[1]].min)
          # end
          
          # options.merge!(output: "file") if options[:filename]
          # options.merge!({ plot: { title: "%s %s %.4f" % [title, "AUC:", area] } })
    
          # plot([{ x: roc_curve.map(&:first), y: roc_curve.map(&:last), style: "lines" }], options)
        end
      end
    end

    module Gnuplot
      class << self
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
          options[:plot] = (options[:plot] || {}).merge({
            title:  title,
            yrange: "[0:#{groups.map(&:last).max * 1.1}]",
            xtics:  "#{[bin_size, 5].max}",
            style:  "fill solid 0.5 border"
          })
    
          plot([{ x: groups.map(&:first), y: groups.map(&:last), style: "boxes" }], options)
        end
        
        def roc(data, title = "", options = {})
          # data = [[true_score_1, true_score_2, ...], [false_score_1, false_score_2, ...]]~
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
          
          plot(data.map { |hash| { title: hash[:label], x: hash[:data].map(&:first), y: hash[:data].map(&:last), style: "linespoints" }.merge(hash[:options] || {}) }, options)
        end
      end
    end
  end
end