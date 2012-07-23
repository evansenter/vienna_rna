require "bio"
require "active_support/inflector"
require "active_support/core_ext/class"
require "active_support/core_ext/module/aliasing"

module ViennaRna
  @debug = true
  
  Dir[File.join(File.dirname(__FILE__), "/modules/*")].each do |file|
    autoload File.basename(file, ".rb").camelize.to_sym, file
  end
  
  def self.const_missing(name)
    if Base.exec_exists?(name)
      module_eval do
        const_set(name, Class.new(Base))
      end
    end
  end
  
  def self.debug
    @debug
  end
  
  def self.debug=(value)
    @debug = value
  end
end