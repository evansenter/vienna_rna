module ViennaRna
  class Base
    class_inheritable_accessor :exec_name
    
    class << self
      def method_added(name)
        if name == :run
          unless @chaining
            @chaining = true
            alias_method_chain :run, :hooks
          else
            remove_instance_variable(:@chaining)
          end
        end
      end
      
      def exec_exists?(name)
        !%x[which rna#{name.to_s.downcase}].empty?
      end
    end
    
    attr_reader :fasta
    
    def exec_name
      @exec_name || "rna#{self.class.name.split('::').last.underscore}"
    end
    
    def initialize(fasta)
      @fasta = fasta
    end
    
    def run_with_hooks(flags = {})
      pre_run_check
      response = run_without_hooks
      self.class.method_defined?(:post_process) ? post_process(response) : response  
    end
    
    def pre_run_check
      if self.class.exec_exists?(exec_name)
        raise RuntimeError.new("#{exec_name} is not defined on this machine")
      end
    end
    
    def stringify_flags(flags)
      flags.inject("") { |string, flag| (string + (" %s %s" % flag)).strip }
    end
    
    def run(flags = {})
      %x[echo #{fasta.seq} | #{exec_name} #{stringify_flags(flags)}]
    end
  end
end