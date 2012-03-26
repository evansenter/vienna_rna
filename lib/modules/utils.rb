# "/Users/evansenter/Source/mirna_5.1/hairpin.fa"

module ViennaRna
  module Utils
    class << self
      def fastas_from_file(path)
        # Force it to not be lazy.
        Bio::FlatFile.auto(path).to_enum.map { |fasta| fasta }
      end
    end
  end
end