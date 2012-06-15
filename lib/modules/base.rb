module ViennaRna
  class Base
    class_attribute :executable_name
    
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
      
      def run(data, flags = {})
        new(data).run(flags)
      end
      
      def batch(fastas = [])
        ViennaRna::Batch.new(self, fastas).tap do |batch|
          if const_defined?(:Batch)
            @@me = self
            
            batch.singleton_class.class_eval { include @@me.const_get(:Batch) }
          end
        end
      end
    end
    
    attr_reader :fasta, :response
    
    def exec_name
      executable_name || "rna#{self.class.name.split('::').last.underscore}"
    end
    
    def exec_sequence_format
      fasta.seq
    end
    
    def initialize(data)
      # Doesn't support structures on the third line yet.
      @fasta = case data
      when Bio::FastaFormat then data
      when String           then Bio::FastaFormat.new(data.split(/\n/).length > 1 ? data : ">\n%s" % data)
      end
    end
    
    def run_with_hooks(flags = {})
      tap do
        pre_run_check unless respond_to?(:run_command)
        @response = run_without_hooks(flags)
        post_process if respond_to?(:post_process)
      end
    end
    
    def pre_run_check
      if self.class.exec_exists?(exec_name)
        raise RuntimeError.new("#{exec_name} is not defined on this machine")
      end
    end
    
    def stringify_flags(flags)
      flags.inject("") { |string, (flag, value)| (string + (value == :empty ? " -%s" % flag : " -%s %s" % [flag, value])).strip }
    end
    
    def run(flags = {})
      command = if respond_to?(:run_command)
        method(:run_command).arity.zero? ? run_command : run_command(flags)
      else
        "echo #{exec_sequence_format} | #{exec_name} #{stringify_flags(flags)}"
      end
      
      puts command if ViennaRna.debug
        
      %x[#{command}]
    end
  end
end