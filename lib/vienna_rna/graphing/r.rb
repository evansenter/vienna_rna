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
        
        def overlay(data, title: nil, type: ?l, x_label: "Independent", y_label: "Dependent", legend: "topleft", filename: false)
          # data: [{ data: [[x_0, y_0], ..., [x_n, y_n]], legend: "Line 1" }, ...]
          
          x_points = data.map { |hash| hash[:data].map(&:first) }
          y_points = data.map { |hash| hash[:data].map(&:last) }
          x_range  = Range.new(x_points.map(&:min).min.floor, x_points.map(&:max).max.ceil)
          y_range  = Range.new(y_points.map(&:min).min.floor, y_points.map(&:max).max.ceil)
          
          graph do |r|
            r.eval("%s('%s', 6, 6)" % [
              writing_file?(filename) ? "pdf" : "quartz", 
              writing_file?(filename) ? filename : "Graph", 
            ])
            
            r.assign("legend.titles", data.each_with_index.map { |hash, index| hash[:legend] || "Line #{index + 1}" })
            r.eval("line.colors <- rainbow(%d)" % data.size)
            r.eval("plot(0, 0, type = 'n', cex = .75, cex.axis = .9, xlab = '', ylab = '', xlim = c(%d, %d), ylim = c(%d, %d))" % [
              x_range.min, x_range.max, y_range.min, y_range.max
            ])
            
            data.each_with_index do |hash, index|
              r.assign("line_graph.x.%d" % index, x_points[index])
              r.assign("line_graph.y.%d" % index, y_points[index])
              
              r.eval <<-STR
                lines(
                  line_graph.x.#{index}, 
                  line_graph.y.#{index}, 
                  col  = line.colors[#{index + 1}],
                  type = "#{type}",
                  pch  = #{index}
                )
              STR
            end
            
            r.eval <<-STR
              title(
                xlab     = #{expressionify(x_label)}, 
                ylab     = #{expressionify(y_label)}, 
                main     = #{expressionify(title || "Line Graph")},
                cex.main = .9,
                cex.lab  = .9
              )
            STR
              
            if legend
              r.eval <<-STR
                legend(
                  "#{legend}",
                  legend.titles,
                  bty = "o",
                  bg  = rgb(1, 1, 1, .5, 1),
                  col = line.colors,
                  lty = rep(1, #{data.size}),
                  pch = 0:#{data.size},
                  cex = .6
                )
              STR
            end
            
            r.eval("dev.off()") if writing_file?(filename)
          end
        end

        def line_graph(data, title: nil, type: ?l, x_label: "Independent", y_label: "Dependent", filename: false)
          overlay([{ data: data }], title: title, type: type, x_label: x_label, y_label: y_label, legend: false, filename: filename)
        end
        
        def scatterplot(data, title: nil, x_label: "Independent", y_label: "Dependent", filename: false)
          line_graph(data, title: title, type: ?p, x_label: x_label, y_label: y_label, filename: filename)
        end
        
        def roc(data, title: nil, baseline: true, filename: false)
          # data: [[-0.894, 1.0], [-0.950, 1.0], [0.516, -1.0], ..., [0.815, -1.0], [0.740, -1.0]]
          auc            = ROC.auc(data)
          title_with_auc = title ? "%s (AUC: %.4f)" % [title, auc] : "AUC: %.4f" % auc
          overlay(
            [{ data: ROC.curve_points(data) }, { data: [[0, 0], [1, 1]] }], 
            title:    title_with_auc, 
            x_label:  "False positive rate", 
            y_label:  "True positive rate", 
            legend:   false, 
            filename: filename
          )
        end
        
        def roc_overlay(data, title: nil, auc_in_legend: true, filename: false)
          # [{ data: [[-0.894, 1.0], [-0.950, 1.0], [0.516, -1.0], ..., [0.815, -1.0], [0.740, -1.0]], legend: "ROC 1" }, ...]
          formatted_data = data.map do |hash|
            curve_points = ROC.curve_points(hash[:data])
            
            if auc_in_legend
              auc    = ROC.auc(hash[:data])
              legend = hash[:legend] ? "%s (AUC: %.4f)" % [hash[:legend], auc] : "AUC: %.4f" % auc
              
              hash.merge({ data: curve_points, legend: legend })
            else
              hash.merge({ data: curve_points })
            end
          end
          
          
          overlay(
            formatted_data, 
            title:    title, 
            x_label:  "False positive rate", 
            y_label:  "True positive rate", 
            legend:   "bottomright", 
            filename: filename
          )
        end
        
        def histogram(data, title: nil, x_label: "Bins", num_bins: false, bin_size: 1, x_arrow: false, relative: false, filename: false)
          half     = bin_size / 2.0
          range    = Range.new((data.min - half).floor, (data.max + half).ceil)
          breaks   = num_bins ? num_bins : (range.min + half).step(range.max + half, bin_size).to_a
          
          graph do |r|
            r.assign("histogram.data", data)
            r.assign("histogram.breaks", breaks)
            
            r.eval("%s('%s', 6, 6)" % [
              writing_file?(filename) ? "pdf" : "quartz", 
              writing_file?(filename) ? filename : "Histogram", 
            ])
            
            r.eval <<-STR
              hist(
                histogram.data, 
                breaks   = histogram.breaks, 
                xlab     = #{expressionify(x_label)}, 
                main     = #{expressionify(title || "Histogram")}, 
                freq     = #{relative ? 'F' : 'T'},
                cex.main = 0.9,
                cex.lab  = 0.9,
                cex.axis = 0.9
              )
            STR
            
            r.eval("abline(v = #{x_arrow}, lty = 'dashed')") if x_arrow
            
            r.eval("dev.off()") if writing_file?(filename)
          end
        end
        
        def matrix_heatmap(x, y, z, title: nil, x_label: "Column index", y_label: "Row index", filename: false, num_colors: 64)
          graph do |r|
            if r.pull("ifelse('Matrix' %in% rownames(installed.packages()), 1, -1)") > 0
              if forced_square = (x.max != y.max)
                x << [x, y].map(&:max).max
                y << [x, y].map(&:max).max
                z << 0
              end
              
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
              
              generate_graph("Heatmap") do
                <<-STR
                  filtered.values <- Filter(function(i) { is.finite(i) & i != 0 }, matrix.x)
                  print(apply(as.matrix(matrix.data), 2, rev))
                  print(c(sort(filtered.values)[2], max(filtered.values)))
                
                  image(
                    x    = 1:max(c(dim(matrix.data)[[1]], dim(matrix.data)[[2]])), 
                    y    = 1:max(c(dim(matrix.data)[[1]], dim(matrix.data)[[2]])), 
                    z    = as.matrix(matrix.data),
                    col  = rev(heat.colors(#{num_colors})),
                    zlim = #{forced_square ? "c(sort(filtered.values)[2], max(filtered.values))" : "c(min(filtered.values), max(filtered.values))"},
                    xlab = "#{x_label} (1-indexed)",
                    ylab = "#{y_label} (1-indexed)"
                  )
                  title(#{expressionify(title || "Matrix Heatmap")})
                STR
              end
            else
              puts "Please install the Matrix package for R before using this function."
            end
          end
        end
        
        private
        
        def generate_graph(window_title = "ViennaRNA Graph in R", &block)
          r, filename = block.binding.eval("[r, filename]")
          
          r.eval("%s('%s', 6, 6)" % [
            writing_file?(filename) ? "pdf" : "quartz", 
            writing_file?(filename) ? filename : window_title, 
          ])
          
          r.eval(yield)
          
          r.eval("dev.off()") if writing_file?(filename)
        end
        
        def writing_file?(filename)
          filename && (filename = filename.end_with?(".pdf") ? filename : filename + ".pdf")
        end
        
        def expressionify(string)
          string.start_with?("expression") ? string : string.inspect
        end
      end
    end
  end
end