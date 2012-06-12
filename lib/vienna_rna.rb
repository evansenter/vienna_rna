require "bio"
require "active_support/inflector"
require "active_support/core_ext/class"
require "active_support/core_ext/module/aliasing"

# Clean up this include order.
Dir[File.join(File.dirname(__FILE__), "/modules/*")].each do |file|
  require file
end

module ViennaRna
  def self.const_missing(name)
    if Base.exec_exists?(name)
      module_eval do
        const_set(name, Class.new(Base))
      end
    end
  end
end