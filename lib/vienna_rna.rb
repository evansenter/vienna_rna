require "set"
require "bio"
require "shuffle"
require "matrix"
require "rinruby"
require "rroc"
require "active_support/inflector"
require "active_support/core_ext/class"
require "active_support/core_ext/module/aliasing"

begin; R.quit; rescue IOError; end

module ViennaRna
  @debug = true
  
  Dir[File.join(File.dirname(__FILE__), "vienna_rna", "modules", "*.rb")].each do |file|
    # Doesn't support autoloading modules that are of the form: TwoWords
    autoload(File.basename(file, ".rb").camelize.to_sym, "vienna_rna/modules/#{File.basename(file, '.rb')}")
  end
  
  def self.const_missing(name)
    if const_defined?(name)
      const_get(name)
    elsif Base.exec_exists?(name)
      module_eval do
        const_set(name, Class.new(Base))
      end
    end
  end
  
  def self.deserialize(string)
    YAML.load(File.exist?(string) ? File.read(string) : string)
  end

  def self.debugger
    STDERR.puts yield if ViennaRna.debug
  end
  
  def self.debug
    @debug
  end
  
  def self.debug=(value)
    @debug = value
  end
end

# This dirties up the public namespace, but I use it so many times that I want a shorthand to it
unless defined? RNA
  def RNA(*args)
    RNA.from_array(args)
  end
end

module RNA
  def self.method_missing(name, *args, &block)
    if "#{name}" =~ /^from_\w+$/
      ViennaRna::Rna.send("init_#{name}", *args)
    else super end
  end
end