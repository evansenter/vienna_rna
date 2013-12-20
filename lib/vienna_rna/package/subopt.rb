module ViennaRna
  module Package
    class Subopt < Base
      attr_reader :structures
    
      def post_process
        @structures = response.split(/\n/)[1..-1].map { |output| RNA.from_string(data.seq, output.split(/\s+/).first) }
      end
    
      def bin(count = 1)
        run(p: count).structures.inject(Hash.new { |hash, key| hash[key] = 0 }) do |hash, structure|
          hash.tap do
            hash[structure] += 1
          end
        end
      end
    end
  end
end
