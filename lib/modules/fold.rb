# Rip this out, infer it through metaprogramming.

module ViennaRna
  class Fold < Base
    def post_process(response)
      structure = response.split(/\n/).last.gsub(/ \(\s*-?\d*\.\d*\)$/, "")
      
      unless fasta.seq.length == structure.length
        raise "Sequence: '#{fasta.seq}'\nStructure: '#{structure}'"
      else
        structure
      end
    end
  end
end