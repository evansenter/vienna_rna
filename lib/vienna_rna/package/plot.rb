module ViennaRna
  module Package
    class Plot < Base
      self.call_with     = [ :comment, :seq, :str]
      self.default_flags = {
        t: 0,
        o: "svg"
      }

      def run_command(flags)
        "cat %s | %s %s" % [
          data.temp_fa_file!,
          exec_name,
          stringify_flags(flags)
        ]
      end
    end
  end
end
