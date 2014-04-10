Gem::Specification.new do |spec|
  spec.name        = "vienna_rna"
  spec.version     = "0.14.0"
  spec.licenses    = %w(MIT)
  spec.summary     = "Bindings to the Vienna RNA package, and other major command line utilities for RNA."
  spec.description = "A Ruby 2.0 API for interacting with command line tools involving RNA molecules through a standard interface."
  spec.authors     = ["Evan Senter"]
  spec.email       = "evansenter@gmail.com"
  spec.files       = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  spec.homepage    = "http://rubygems.org/gems/vienna_rna"

  spec.add_runtime_dependency("activesupport", "~> 4.0")
  spec.add_runtime_dependency("shuffle",       "~> 0.1")
  spec.add_runtime_dependency("rinruby",       "~> 2.0")
  spec.add_runtime_dependency("rroc",          "~> 0.1")

  spec.post_install_message = "DEPRECATED: The vienna_rna gem has been deprecated and has been replaced by wrnap."
end
