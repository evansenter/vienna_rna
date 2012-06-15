module ViennaRna
  class FftInR < Base
    attr_reader :processed_response, :points, :total_count, :precision
    
    def initialize(points, total_count, precision)
      @points      = points
      @total_count = total_count
      @precision   = precision
    end
    
    def run_command
      vector = "c(%s)" % points.map { |point| 10 ** precision * point / total_count }.join(", ")
      "Rscript -e 'vector <- #{vector}; fft(vector) / length(vector);'" % vector
    end
    
    def post_process
      @processed_response = response.split(/\n/).map do |line| 
        line.strip.match(/\[\d+\]\s+(.*)$/)[1].split(/\s+/)
      end.flatten.map do |i|
        i.match(/(-?\d+\.\d+e[\+-]\d+)/)[1].to_f
      end.map do |i|
        precision.zero? ? i : i.truncate / 10.0 ** precision
      end
    end
  end
end
