module ViennaRna
  module Package
    class Subopt < Base
      attr_reader :structures

      def post_process
        @structures = response.split(/\n/)[1..-1].map do |output|
          structure, mfe = output.split(/\s+/)

          RNA.from_string(data.seq, structure).tap do |rna|
            rna.instance_variable_set(:@mfe, mfe.to_f)
            rna.class_eval { attr_reader :mfe }
          end
        end
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
